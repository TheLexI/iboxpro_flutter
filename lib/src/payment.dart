import 'types.dart';

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Класс для связи с терминалом 2can
/// Дублирует функционал PaymentConroller на ios
/// Класс не имеет возможности работать параллельно в связи с нижележащей имплементацией библиотеки iboxpro
class PaymentController {
  static final MethodChannel _channel = MethodChannel('iboxpro_flutter')..setMethodCallHandler(_handleMethodCall);

  static Function(Map<dynamic, dynamic>) _onPaymentStart;
  static Function(Map<dynamic, dynamic>) _onPaymentError;
  static Function(Map<dynamic, dynamic>) _onPaymentComplete;
  static Function(Map<dynamic, dynamic>) _onReaderSetBTDevice;
  static Function(Map<dynamic, dynamic>) _onReaderEvent;
  static Function(Map<dynamic, dynamic>) _onLogin;
  static Function(Map<dynamic, dynamic>) _onInfo;
  static Function(Map<dynamic, dynamic>) _onPaymentAdjust;

  /// Производит логин в систему
  /// [onLogin] вызывается при завершении операции с результатом операции
  static Future<void> login({
    @required String email,
    @required String password,
    Function(Map<dynamic, dynamic>) onLogin
  }) async {
    _onLogin = onLogin;

    await _channel.invokeMethod('login', {
      'email': email,
      'password': password
    });
  }

  /// Начинает операцию принятия оплаты терминалом
  ///
  /// [inputType] вид оплаты, все возможные значения в [InputType]
  ///
  /// [currencyType] вид валют, все возможные значения в [CurrencyType]
  ///
  /// [onPaymentStart] вызывается когда началась оплата с карты (установлена успешная связь между картой и терминалом)
  ///
  /// [onPaymentError] вызывается при любой ошибке оплаты
  ///
  /// [onPaymentComplete] вызывается по завершению оплаты, с данными оплаты и флагом requiredSignature,
  /// если флаг установлен то требуется вызывать метод [PaymentController.adjustPayment]
  ///
  /// [onReaderEvent] вызывается при установки связи и выполнения команд на терминале
  ///
  /// Важно: Если вход в систему не осуществлен или нет связи с терминалом,
  /// то операция не начнется, при этом ошибки никакой не будет
  static Future<void> startPayment({
    @required double amount,
    @required int inputType,
    @required int currencyType,
    @required String description,
    String receiptEmail,
    String receiptPhone,
    Function(Map<dynamic, dynamic>) onPaymentStart,
    Function(Map<dynamic, dynamic>) onPaymentError,
    Function(Map<dynamic, dynamic>) onPaymentComplete,
    Function(Map<dynamic, dynamic>) onReaderEvent
  }) async {
    _onPaymentStart = onPaymentStart;
    _onPaymentError = onPaymentError;
    _onPaymentComplete = onPaymentComplete;
    _onReaderEvent = onReaderEvent;

    await _channel.invokeMethod('startPayment', {
      'amount': amount,
      'inputType': inputType,
      'currencyType': currencyType,
      'description': description,
      'receiptEmail': receiptEmail,
      'receiptPhone': receiptPhone
    });
  }

  /// Начинает операцию добавления подписи к оплате терминала
  ///
  /// [onPaymentAdjust] вызывается по завершению операции с результатом операции
  static Future<void> adjustPayment({
    @required String trId,
    @required Uint8List signature,
    String receiptEmail,
    String receiptPhone,
    Function(Map<dynamic, dynamic>) onPaymentAdjust
  }) async {
    _onPaymentAdjust = onPaymentAdjust;
    await _channel.invokeMethod('adjustPayment', {
      'trId': trId,
      'signature': signature,
      'receiptEmail': receiptEmail,
      'receiptPhone': receiptPhone
    });
  }

  /// Начинает операцию по получению информации об оплате
  ///
  /// [onInfo] вызывается по завершению операции с результатом операции
  static Future<void> info({
    @required String trId,
    Function(Map<dynamic, dynamic>) onInfo
  }) async {
    _onInfo = onInfo;
    await _channel.invokeMethod('info', {
      'trId': trId
    });
  }

  /// Начинает операцию поиска терминала
  ///
  /// [onReaderSetBTDevice] вызывается по завершению операции с результатом операции
  ///
  /// Важно: Всегда выбирает первый найденный терминал
  static Future<void> searchBTDevice({
    @required int readerType,
    Function(Map<dynamic, dynamic>) onReaderSetBTDevice
  }) async {
    _onReaderSetBTDevice = onReaderSetBTDevice;

    await _channel.invokeMethod('searchBTDevice', {
      'readerType': readerType
    });
  }

  /// Устанавливает таймаут для операций с АПИ iboxpro
  static Future<void> setRequestTimeout({
    @required int timeout
  }) async {
    await _channel.invokeMethod('setRequestTimeout', {
      'timeout': timeout
    });
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onLogin':
        if (_onLogin != null) {
          _onLogin(call.arguments);
          _onLogin = null;
        }

        break;
      case 'onInfo':
        if (_onInfo != null) {
          _onInfo(call.arguments);
          _onInfo = null;
        }

        break;
      case 'onPaymentStart':
        if (_onPaymentStart != null) {
          _onPaymentStart(call.arguments);
          _onPaymentStart = null;
        }

        break;
      case 'onPaymentError':
        if (_onPaymentError != null) {
          _onPaymentError(call.arguments);
          _onPaymentError = null;
        }

        break;
      case 'onPaymentComplete':
        if (_onPaymentComplete != null) {
          _onPaymentComplete(call.arguments);
          _onPaymentComplete = null;
        }

        break;
      case 'onPaymentAdjust':
        if (_onPaymentAdjust != null) {
          _onPaymentAdjust(call.arguments);
          _onPaymentAdjust = null;
        }

        break;
      case 'onReaderSetBTDevice':
        if (_onReaderSetBTDevice != null) {
          _onReaderSetBTDevice(call.arguments);
          _onReaderSetBTDevice = null;
        }

        break;
      case 'onReaderEvent':
        if (_onReaderEvent != null) {
          _onReaderEvent(call.arguments);
          _onReaderEvent = null;
        }

        break;
      default:
        throw MissingPluginException();
    }
  }
}