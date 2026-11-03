// KIS 국내 주문 — core `OrderBroker` 포트 구현(설계 13 §8 R33 D12 · D16 · D18 · D19 · R37 Y1~Y8 · 02 §5-1 · 07 §6-3).
//
// 🔴 계좌 하나(= 앱키 하나 = [KisRestClient] 하나)에 한 벌이다(R33 D18). 유량 문은 시세 · 조회와 같이 쓴다(R29 L4).
// 🔴 TR 은 접속 환경에서만 나온다([KisTr.of]) — 도메인만 바꾸고 TR 을 그대로 두면 실주문이 나간다(R29 L2).
// 🔴 주문 POST 의 재시도 · 분류는 [KisRestClient.postOrder] 한 곳이다 — 여기서 다시 보내지 않는다(NR-2).
// 🔴 결과 불명은 `OrderOutcomeUnknown` 으로 던진다(순서기가 UNKNOWN 으로 기록한다). 분명한 거절은 `BrokerRejected` 값.
// 🟡 실전 TR · hashkey · 체결조회 이어받기 머리는 실측 전이다(07 §6-3 «실전 키 때» · R37 Y3 · Y6). 예수금 칸은 모의 실측됨(R41 J8).
// 🆕 E10g — 대사 잔고 포트(`BrokerBalanceSource` · 설계 13 §8 R41): 보유 = `output1` `pdno` → `hldg_qty` · 관측 현금 = `dnca_tot_amt` · 이어받기.
//    🟡 실물 보유 행은 아직 못 봤다(실응답 2026-11-04 = 보유 0주) — 칸 이름은 KIS 문서 · 실험 278 의 같은 해석.

import 'package:core_engine/core_engine.dart'
    show
        AccountBroker,
        BrokerAccepted,
        BrokerBalance,
        BrokerOrderRequest,
        BrokerRejected,
        BrokerSubmitResult,
        DailyFillRow,
        OrderOutcomeUnknown,
        OrderTypes;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;

import 'kis_environment.dart';
import 'kis_quotes.dart' show KisRejected;
import 'kis_rest_client.dart';

/// 국내 주문 · 조회 경로(02 §5-1 · 07 §6-3).
abstract final class KisOrderPaths {
  /// 현금 매수 · 매도.
  static const String orderCash = '/uapi/domestic-stock/v1/trading/order-cash';

  /// 정정 · 취소.
  static const String reviseCancel =
      '/uapi/domestic-stock/v1/trading/order-rvsecncl';

  /// 일별주문체결조회.
  static const String dailyFills =
      '/uapi/domestic-stock/v1/trading/inquire-daily-ccld';

  /// 잔고.
  static const String balance =
      '/uapi/domestic-stock/v1/trading/inquire-balance';
}

/// 환경별 TR(R37 Y3) — 모의 `V` · 실전 `T`(🟡 실전 실측 전).
final class KisTr {
  const KisTr._(
    this.buy,
    this.sell,
    this.cancel,
    this.dailyFills,
    this.balance,
  );

  /// 모의(07 §6-3 실측).
  static const KisTr mock = KisTr._(
    'VTTC0012U',
    'VTTC0011U',
    'VTTC0013U',
    'VTTC0081R',
    'VTTC8434R',
  );

  /// 실전(🟡 실측 전).
  static const KisTr live = KisTr._(
    'TTTC0012U',
    'TTTC0011U',
    'TTTC0013U',
    'TTTC0081R',
    'TTTC8434R',
  );

  /// [environment] 의 TR — 🔴 이것 말고 TR 을 고르는 길은 없다.
  static KisTr of(KisEnvironment environment) => switch (environment) {
    KisEnvironment.mock => mock,
    KisEnvironment.live => live,
  };

  /// 매수 · 매도 · 취소 · 일별주문체결조회 · 잔고.
  final String buy, sell, cancel, dailyFills, balance;
}

/// 체결조회 이어받기 상한(R37 Y6) — 하루 주문은 60건 이하(SAF-401)라 넘으면 이상이다.
const int kKisFillPageLimit = 10;

/// 🆕 E10g — 잔고 이어받기 상한(R41 J5) — 보유 종목은 30 이하(SAF-203)라 넘으면 이상이다.
const int kKisBalancePageLimit = 10;

/// 체결조회 한 행 + 취소에 쓰는 지점 번호(`ord_gno_brno`).
class KisFillRow {
  /// 행을 만든다.
  const KisFillRow(this.row, {required this.branch});

  /// 02 `BrokerDailyFill` 꼴의 행.
  final DailyFillRow row;

  /// 주문 지점(`ord_gno_brno` — 취소 본문의 `KRX_FWDG_ORD_ORGNO`).
  final String branch;
}

/// 행 칸 읽기 — KIS 는 소문자 칸이지만 대문자로 오는 응답도 받는다.
String? _field(Map<String, Object?> r, String key) {
  final Object? v = r[key] ?? r[key.toUpperCase()];
  return v is String ? v.trim() : null;
}

String _need(Map<String, Object?> r, String key) {
  final String? v = _field(r, key);
  if (v == null || v.isEmpty) throw FormatException('체결조회 행에 $key 가 없다');
  return v;
}

int _int(Map<String, Object?> r, String key) {
  final int? v = int.tryParse(_need(r, key));
  if (v == null) throw FormatException('체결조회 행의 $key 가 정수가 아니다');
  return v;
}

/// `YYYYMMDD` → ISO 날짜.
TradeDate kisDate(String ymd) {
  if (!RegExp(r'^\d{8}$').hasMatch(ymd)) {
    throw FormatException('날짜 꼴이 아니다(YYYYMMDD)', ymd);
  }
  return TradeDate(
    '${ymd.substring(0, 4)}-${ymd.substring(4, 6)}-${ymd.substring(6)}',
  );
}

/// ISO 날짜 → `YYYYMMDD`.
String kisYmd(TradeDate d) => d.yyyyMmDd.replaceAll('-', '');

/// 일별주문체결조회 `output1` 한 행 → [KisFillRow](02 `BrokerDailyFill` · R37 Y6). 모르는 값은 FormatException.
KisFillRow parseKisFillRow(Map<String, Object?> r) {
  final OrderSide side = switch (_need(r, 'sll_buy_dvsn_cd')) {
    '01' => OrderSide.sell,
    '02' => OrderSide.buy,
    final String v => throw FormatException('모르는 매도매수 구분', v),
  };
  final String? unitPrice = _field(r, 'ord_unpr');
  final String? original = _field(r, 'orgn_odno');
  final String? time = _field(r, 'ord_tmd');
  return KisFillRow(
    DailyFillRow(
      orderDate: kisDate(_need(r, 'ord_dt')),
      odno: _need(r, 'odno'),
      isCancelRow: _field(r, 'cncl_yn') == 'Y',
      originalOdno: original == null || original.isEmpty ? null : original,
      symbol: _need(r, 'pdno'),
      side: side,
      orderQty: _int(r, 'ord_qty'),
      orderPrice: unitPrice == null || unitPrice.isEmpty
          ? null
          : Decimal.parse(unitPrice),
      orderTime: time == null || time.isEmpty ? null : time,
      cumFilledQty: _int(r, 'tot_ccld_qty'),
      cumFilledAmount: Decimal.parse(_need(r, 'tot_ccld_amt')),
      remainingQty: _int(r, 'rmn_qty'),
      cancelConfirmedQty: int.tryParse(_field(r, 'cncl_cfrm_qty') ?? '') ?? 0,
    ),
    branch: _field(r, 'ord_gno_brno') ?? '',
  );
}

/// 잔고 응답 → 매수에 쓸 예수금(R37 Y7 — `output2[0].prvs_rcdl_excc_amt` · D+2 정산 예수금 · 음수 = 0).
Decimal parseKisOrderableCash(Map<String, Object?> body) {
  final Object? out = body['output2'];
  final Object? first = out is List<Object?> && out.isNotEmpty
      ? out.first
      : out;
  if (first is! Map<String, Object?>) {
    throw const FormatException('잔고 응답에 output2 가 없다');
  }
  final String? v = _field(first, 'prvs_rcdl_excc_amt');
  final Decimal? cash = v == null ? null : Decimal.tryParse(v);
  if (cash == null) {
    throw const FormatException(
      '잔고 output2 에 prvs_rcdl_excc_amt 가 없거나 숫자가 아니다',
    );
  }
  return cash < Decimal.zero ? Decimal.zero : cash;
}

/// 🆕 E10g — 잔고 `output1` → 종목 → 보유 수량(R41 J3). 0 은 넣지 않고 같은 종목 여러 행은 더한다.
/// 칸이 없거나 정수가 아니면 FormatException(지어내지 않는다 — 대사는 그 계좌를 «대사 못 함»으로 둔다).
Map<String, int> parseKisHoldings(List<Object?> rows) {
  final Map<String, int> out = <String, int>{};
  for (final Object? row in rows) {
    if (row is! Map<String, Object?>) {
      throw const FormatException('잔고 output1 행이 객체가 아니다');
    }
    final String? symbol = _field(row, 'pdno');
    if (symbol == null || symbol.isEmpty) {
      throw const FormatException('잔고 행에 pdno 가 없다');
    }
    final int? qty = int.tryParse(_field(row, 'hldg_qty') ?? '');
    if (qty == null || qty < 0) {
      throw FormatException('잔고 행의 hldg_qty 가 0 이상 정수가 아니다', symbol);
    }
    if (qty == 0) continue;
    out[symbol] = (out[symbol] ?? 0) + qty;
  }
  return out;
}

/// 🆕 E10g — 잔고 응답 → 관측 현금(R41 J4 — `output2[0].dnca_tot_amt` · 예수금 총금액 · D+0). 없거나 숫자가 아니면 null.
Decimal? parseKisObservedCash(Map<String, Object?> body) {
  final Object? out = body['output2'];
  final Object? first = out is List<Object?> && out.isNotEmpty
      ? out.first
      : out;
  if (first is! Map<String, Object?>) return null;
  final String? v = _field(first, 'dnca_tot_amt');
  return v == null ? null : Decimal.tryParse(v);
}

DateTime _realNow() => DateTime.now().toUtc();

/// 계좌 하나의 KIS 주문 브로커(core `OrderBroker` 구현 · R37 · 🆕 E10g `BrokerBalanceSource` · R41).
final class KisOrderBroker implements AccountBroker {
  /// 브로커를 만든다. [now] = 접수 응답의 주문일(KST 날짜)을 정하는 시계.
  KisOrderBroker(this._client, {DateTime Function()? now})
    : _now = now ?? _realNow;

  final KisRestClient _client;
  final DateTime Function() _now;

  KisTr get _tr => KisTr.of(_client.environment);

  Map<String, String> get _account => <String, String>{
    'CANO': _client.credentials.accountNo,
    'ACNT_PRDT_CD': _client.credentials.productCode,
  };

  /// 지금의 KST 날짜.
  TradeDate get _kstToday {
    final DateTime k = _now().toUtc().add(const Duration(hours: 9));
    String two(int n) => n.toString().padLeft(2, '0');
    return TradeDate('${k.year}-${two(k.month)}-${two(k.day)}');
  }

  /// 매수 · 매도 본문(R37 Y4 — 실험 278 그대로).
  Map<String, String> orderBody(BrokerOrderRequest request) {
    if (request.quantity < 1) {
      throw ArgumentError.value(request.quantity, 'quantity', '1 이상이어야 한다');
    }
    final (String dvsn, String price) = switch (request.orderType) {
      OrderTypes.limit => ('00', _wonText(request.limitPrice)),
      OrderTypes.market when request.limitPrice == null => ('01', '0'),
      _ => throw ArgumentError.value(
        request.orderType,
        'orderType',
        '지정가(가격 있음) · 시장가(가격 없음)만 보낸다',
      ),
    };
    return <String, String>{
      ..._account,
      'PDNO': request.symbol,
      'ORD_DVSN': dvsn,
      'ORD_QTY': '${request.quantity}',
      'ORD_UNPR': price,
    };
  }

  String _wonText(Decimal? price) {
    if (price == null || price <= Decimal.zero || !price.isInteger) {
      throw ArgumentError.value(price, 'limitPrice', '지정가는 양의 정수 원이어야 한다');
    }
    return price.toBigInt().toString();
  }

  @override
  Future<BrokerSubmitResult> submit(BrokerOrderRequest request) async {
    final Map<String, String> body = orderBody(request);
    final KisOrderPost post = await _client.postOrder(
      KisOrderPaths.orderCash,
      request.side == OrderSide.buy ? _tr.buy : _tr.sell,
      body,
    );
    return _result(post);
  }

  BrokerSubmitResult _result(KisOrderPost post) => switch (post) {
    KisOrderAccepted(:final KisResponse response) => BrokerAccepted(
      odno: _odno(response),
      orderDate: _kstToday,
    ),
    KisOrderRefused(:final String code, :final String message) =>
      BrokerRejected(code: code, message: message),
    KisOrderUnknown(:final String reason, :final int attempts) =>
      throw OrderOutcomeUnknown('KIS 주문 결과 불명 — $reason(전송 $attempts)'),
  };

  String _odno(KisResponse r) {
    final Object? out = r.body?['output'];
    final String? odno = out is Map<String, Object?>
        ? _field(out, 'odno')
        : null;
    if (odno == null || odno.isEmpty) {
      // 접수됐는데 번호를 모른다 — 기록할 수 없으니 결과 불명으로 보낸다(R37 Y8).
      throw const OrderOutcomeUnknown('접수 응답에 ODNO 가 없다');
    }
    return odno;
  }

  @override
  Future<BrokerSubmitResult> cancel(String brokerOrderNo) async {
    final int colon = brokerOrderNo.indexOf(':');
    if (colon < 0) {
      throw ArgumentError.value(
        brokerOrderNo,
        'brokerOrderNo',
        '{주문일}:{ODNO} 꼴이 아니다',
      );
    }
    final TradeDate date = TradeDate(brokerOrderNo.substring(0, colon));
    final String odno = brokerOrderNo.substring(colon + 1);
    // 지점 번호는 그날 체결조회의 원주문 행에서 찾는다(R37 Y5).
    final List<KisFillRow> rows = await fillRows(date);
    KisFillRow? original;
    for (final KisFillRow r in rows) {
      if (!r.row.isCancelRow && r.row.odno == odno) original = r;
    }
    if (original == null || original.branch.isEmpty) {
      return const BrokerRejected(
        code: 'ORDER_NOT_FOUND',
        message: '체결조회에 그 원주문이 없다 — 취소를 보내지 않았다',
      );
    }
    final KisOrderPost post = await _client.postOrder(
      KisOrderPaths.reviseCancel,
      _tr.cancel,
      <String, String>{
        ..._account,
        'KRX_FWDG_ORD_ORGNO': original.branch,
        'ORGN_ODNO': odno,
        'ORD_DVSN': '00',
        'RVSE_CNCL_DVSN_CD': '02',
        'ORD_QTY': '0',
        'ORD_UNPR': '0',
        'QTY_ALL_ORD_YN': 'Y',
      },
    );
    return _result(post);
  }

  /// 일별주문체결조회 — 그날 하루 · 전 종목 · 이어받기(R37 Y6). 실패는 `KisUnavailable` · `KisRejected`.
  Future<List<KisFillRow>> fillRows(TradeDate orderDate) async {
    final String ymd = kisYmd(orderDate);
    final List<KisFillRow> out = <KisFillRow>[];
    String fk = '';
    String nk = '';
    String cont = '';
    for (int page = 0; page < kKisFillPageLimit; page++) {
      final KisResponse r = await _client.get(
        KisOrderPaths.dailyFills,
        _tr.dailyFills,
        <String, String>{
          ..._account,
          'INQR_STRT_DT': ymd,
          'INQR_END_DT': ymd,
          'SLL_BUY_DVSN_CD': '00',
          'INQR_DVSN': '00',
          'PDNO': '',
          'CCLD_DVSN': '00',
          'ORD_GNO_BRNO': '',
          'ODNO': '',
          'INQR_DVSN_3': '00',
          'INQR_DVSN_1': '',
          'CTX_AREA_FK100': fk,
          'CTX_AREA_NK100': nk,
          'EXCG_ID_DVSN_CD': 'KRX',
        },
        trCont: cont,
      );
      if (!r.ok) {
        throw KisRejected(_tr.dailyFills, r.status, r.msgCd, r.msg1);
      }
      final Object? rows = r.body!['output1'];
      if (rows is List<Object?>) {
        for (final Object? row in rows) {
          if (row is Map<String, Object?>) out.add(parseKisFillRow(row));
        }
      }
      final String nextNk = (r.body!['ctx_area_nk100'] as String? ?? '').trim();
      if (!(r.trCont == 'M' || r.trCont == 'F') || nextNk.isEmpty) return out;
      fk = (r.body!['ctx_area_fk100'] as String? ?? '').trim();
      nk = nextNk;
      cont = 'N';
    }
    throw KisUnavailable('체결조회 쪽이 $kKisFillPageLimit 을 넘는다', kKisFillPageLimit);
  }

  @override
  Future<List<DailyFillRow>> dailyFills(TradeDate orderDate) async =>
      <DailyFillRow>[
        for (final KisFillRow r in await fillRows(orderDate)) r.row,
      ];

  /// 잔고 조회 한 쪽(R41 J6 — 실험 278 과 같은 인자).
  Future<KisResponse> _balancePage({
    String fk = '',
    String nk = '',
    String cont = '',
  }) async {
    final KisResponse r = await _client.get(
      KisOrderPaths.balance,
      _tr.balance,
      <String, String>{
        ..._account,
        'AFHR_FLPR_YN': 'N',
        'OFL_YN': '',
        'INQR_DVSN': '02',
        'UNPR_DVSN': '01',
        'FUND_STTL_ICLD_YN': 'N',
        'FNCG_AMT_AUTO_RDPT_YN': 'N',
        'PRCS_DVSN': '00',
        'CTX_AREA_FK100': fk,
        'CTX_AREA_NK100': nk,
      },
      trCont: cont,
    );
    if (!r.ok) throw KisRejected(_tr.balance, r.status, r.msgCd, r.msg1);
    return r;
  }

  @override
  Future<Decimal> orderableCashKrw() async =>
      parseKisOrderableCash((await _balancePage()).body!);

  /// 🆕 E10g — 잔고(보유 · 관측 현금 · R41 J3~J5) — 이어받기로 보유 행을 다 모은다. 관측 현금 = 첫 쪽.
  @override
  Future<BrokerBalance> balance() async {
    final List<Object?> rows = <Object?>[];
    Decimal? cash;
    String fk = '';
    String nk = '';
    String cont = '';
    for (int page = 0; page < kKisBalancePageLimit; page++) {
      final KisResponse r = await _balancePage(fk: fk, nk: nk, cont: cont);
      final Map<String, Object?> body = r.body!;
      if (page == 0) cash = parseKisObservedCash(body);
      final Object? out = body['output1'];
      if (out is List<Object?>) rows.addAll(out);
      final String nextNk = (body['ctx_area_nk100'] as String? ?? '').trim();
      if (!(r.trCont == 'M' || r.trCont == 'F') || nextNk.isEmpty) {
        return BrokerBalance(holdings: parseKisHoldings(rows), cashKrw: cash);
      }
      fk = (body['ctx_area_fk100'] as String? ?? '').trim();
      nk = nextNk;
      cont = 'N';
    }
    throw KisUnavailable(
      '잔고 쪽이 $kKisBalancePageLimit 을 넘는다',
      kKisBalancePageLimit,
    );
  }
}
