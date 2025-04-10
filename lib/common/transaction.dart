import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/rendering.dart';
import 'package:hex/hex.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:xdag/common/helper.dart';
import 'package:fixnum/fixnum.dart';

class TransactionHelper {

  //有 nonce，奇数公钥，无 remark
  static const String hasNonceOddKeyNoRemark = "e1dc570500000000";
  //有 nonce，偶数公钥，无 remark
  static const String hasNonceEvenKeyNoRemark = "e1dc560500000000";
  //有 nonce，奇数公钥，有 remark
  static const String hasNonceOddKeyHasRemark = "e1dc795500000000";
  //有 nonce，偶数公钥，有 remark
  static const String hasNonceEvenKeyHasRemark = "e1dc695500000000";
  //无 nonce，奇数公钥，无 remark
  static const String noNonceOddKeyNoRemark = "c17d550000000000";
  //无 nonce，偶数公钥，无 remark
  static const String noNonceEvenKeyNoRemark = "c16d550000000000";
  //无 nonce，奇数公钥，有 remark
  static const String noNonceOddKeyHasRemark = "c19d570500000000";
  //无 nonce，偶数公钥，有 remark
  static const String noNonceEvenKeyHasRemark = "c19d560500000000";
  //有 nonce、无 remark、签名时补零
  static const int padZerosHasNonceNoRemarkSigned = 22;
  //有 nonce、有 remark、签名时补零
  static const int padZerosHasNonceHasRemarkSigned = 20;
  //无 nonce、无 remark、签名时补零
  static const int padZerosNoNonceNoRemarkSigned = 24;
  //无 nonce、有 remark、签名时补零
  static const int padZerosNoNonceHasRemarkSigned = 22;
  //有 nonce、无 remark（成块补零）
  static const int padZerosHasNonceNoRemark = 18;
  //有 nonce、有 remark（成块补零）
  static const int padZerosHasNonceHasRemark = 16;
  //无 nonce、无 remark（成块补零）
  static const int padZerosNoNonceNoRemark = 20;
  //无 nonce、有 remark（成块补零）
  static const int padZerosNoNonceHasRemark = 18;


  static String getTransaction(String fromAddress, String toAddress, String remark, double value, bip32.BIP32 wallet, String nonce) {
    bool isMainNet = nonce.trim().isEmpty;
    print('getTransaction: $fromAddress, $toAddress, $remark, $value, $nonce');
    bool isPubKeyEven = wallet.publicKey[0] % 2 == 0;
    String from = checkBase58Address(fromAddress);
    String to = checkBase58Address(toAddress);
    Uint8List remarkBytes = Uint8List(32);
    if (remark.isNotEmpty) {
      var encoder = const Utf8Encoder();
      var remarkBytesList = encoder.convert(remark);
      if (remarkBytesList.length > 32) {
        remarkBytesList = remarkBytesList.sublist(0, 32);
      }
      remarkBytes.setRange(0, remarkBytesList.length, remarkBytesList);
    }
    // amount
    final transVal = xdag2Amount(value);
    final valBytes = Uint8List(8);
    ByteData.view(valBytes.buffer).setUint64(0, transVal, Endian.little);
    // ts
    var t = getCurrentTimestamp();
    var timeBytes = ByteData(8)..setUint64(0, t.toInt(), Endian.little);
    String sb = "0000000000000000";

    if (nonce.trim().isEmpty) {
      //主网
      if (remark.isNotEmpty) {
        sb += (isPubKeyEven ? noNonceEvenKeyHasRemark : noNonceOddKeyHasRemark);
      } else {
        sb += (isPubKeyEven ? noNonceEvenKeyNoRemark : noNonceOddKeyNoRemark);
      }
      sb += HEX.encode(timeBytes.buffer.asUint8List());

      sb += "0000000000000000";

      sb += from;
      // amount
      sb += HEX.encode(valBytes);
      // to
      sb += to;
      // amount
      sb += HEX.encode(valBytes);
      if (remark.isNotEmpty) {
        sb += HEX.encode(remarkBytes);
      }
      var pub = HEX.encode(wallet.publicKey.sublist(1));
      sb += pub;
      Map<String, String> res = transactionSign(sb, wallet, remark.isNotEmpty, isMainNet);
      sb += res['r']!;
      sb += res['s']!;
      if (remark.isNotEmpty) {
        for (var i = 0; i < padZerosNoNonceHasRemark; i++) {
          sb += "00000000000000000000000000000000";
        }
      } else {
        for (var i = 0; i < padZerosNoNonceNoRemark; i++) {
          sb += "00000000000000000000000000000000";
        }
      }
    } else {
      //测试网
      if (remark.isNotEmpty) {
        sb += (isPubKeyEven ? hasNonceEvenKeyHasRemark : hasNonceOddKeyHasRemark);
      } else {
        sb += (isPubKeyEven ? hasNonceEvenKeyNoRemark : hasNonceOddKeyNoRemark);
      }
      sb += HEX.encode(timeBytes.buffer.asUint8List());

      sb += "0000000000000000";
      // print('header: $sb');
      // nonce：前面补 48 个 0
      // 由于rpc查询出来的nonce（rpc查出来的到的结果是String类型），会放在该32字节的后八个字段，然后前面24个字节的零，这后八个字节存放nonce的方式是小端序存放。
      sb += encodeNonceTo32Bytes(nonce);
      // print('nonce: $nonce');
      // print('header + nonce: $sb');
      sb += from;
      // amount
      sb += HEX.encode(valBytes);
      // to
      sb += to;
      // amount
      sb += HEX.encode(valBytes);
      if (remark.isNotEmpty) {
        sb += HEX.encode(remarkBytes);
      }
      var pub = HEX.encode(wallet.publicKey.sublist(1));
      sb += pub;
      Map<String, String> res = transactionSign(sb, wallet, remark.isNotEmpty, isMainNet);
      sb += res['r']!;
      sb += res['s']!;
      if (remark.isNotEmpty) {
        for (var i = 0; i < padZerosHasNonceHasRemark; i++) {
          sb += "00000000000000000000000000000000";
        }
      } else {
        for (var i = 0; i < padZerosHasNonceNoRemark; i++) {
          sb += "00000000000000000000000000000000";
        }
      }
    }

    // print('nonce: $nonce');
    // print('sb: $sb');
    //按照每 64 个字符，打印出来
    // for (var i = 0; i < sb.length; i += 64) {
    //   print(sb.substring(i, i + 64));
    // }
    return sb;
  }

  static String encodeNonceTo32Bytes(String nonce) {
    // 创建 8 字节用于保存小端序的 nonce 值
    final nonceBytes = Uint8List(8);
    ByteData.view(nonceBytes.buffer).setUint64(
      0,
      int.parse(nonce), // 将字符串 nonce 转为 int
      Endian.little, // 小端序写入
    );

    // 前 24 字节（48 个 hex 字符）补 0
    final prefix = '0' * 48;

    // 拼接结果：24 字节全 0 + 8 字节小端 nonce
    return prefix + HEX.encode(nonceBytes);
  }

  static String checkBase58Address(String address) {
    final addrBytes = Helper.base58Decode(address);
    if (addrBytes.length != 24) {
      throw ArgumentError('Transaction receive address length error');
    }
    return "00000000${HEX.encode(addrBytes.sublist(addrBytes.length - 20, addrBytes.length))}";
  }

  static int xdag2Amount(double value) {
    var amount = value.floor();
    var res = amount << 32;
    value -= amount;
    value *= pow(2, 32);
    amount = value.ceil();
    return res + amount;
  }

  static Int64 getCurrentTimestamp() {
    var t0 = DateTime.now().toUtc().millisecondsSinceEpoch * 1000000;
    Int64 t = Int64(t0);
    var sec = t ~/ 1000000000;
    var usec = (t - sec * 1000000000) ~/ 1000;
    var xmsec = (usec << 10) ~/ 1000000;
    return (sec << 10) | xmsec;
  }

  static Map<String, String> transactionSign(String b, bip32.BIP32 wallet, bool hasRemark ,bool isMainNet) {
    String sb = b;
    if (isMainNet) {
      if (hasRemark) {
        for (var i = 0; i < padZerosNoNonceHasRemarkSigned; i++) {
          sb += "00000000000000000000000000000000";
        }
      } else {
        for (var i = 0; i < padZerosNoNonceNoRemarkSigned; i++) {
          sb += "00000000000000000000000000000000";
        }
      }
    } else {
      if (hasRemark) {
        // 11 -> 10
        for (var i = 0; i < padZerosHasNonceHasRemarkSigned; i++) {
          sb += "00000000000000000000000000000000";
        }
      } else {
        // 12 -> 11
        for (var i = 0; i < padZerosHasNonceNoRemarkSigned; i++) {
          sb += "00000000000000000000000000000000";
        }
      }
    }
    var pub = HEX.encode(wallet.publicKey);
    sb += pub;
    var res = HEX.decode(sb);
    var h = sha256.convert(sha256.convert(res).bytes).bytes;
    Uint8List sign = wallet.sign(h as Uint8List);
    var r = sign.sublist(0, 32);
    var s = sign.sublist(32, 64);
    return {
      "r": HEX.encode(r),
      "s": HEX.encode(s),
    };
  }

  static bool isJson(String str) {
    try {
      json.decode(str);
    } catch (e) {
      return false;
    }
    return true;
  }

  static bool checkAddress(String address) {
    try {
      if (address.isEmpty) return false;
      var addrBytes = Helper.base58Decode(address).reversed.toList();
      Helper.base58Decode('4AzP6NX68y854ztnSMuBYLj8KHHAtX5HK').reversed.toList();
      if (addrBytes.length != 24) {
        return false;
      }
      final addrBytes20 = addrBytes.sublist(0, 20);
      final addrBytes4 = addrBytes.sublist(20, 24);
      var h = sha256.convert(sha256.convert(addrBytes20).bytes).bytes;
      h = h.sublist(0, 4);
      // 比较 h 和 addrBytes4
      for (var i = 0; i < 4; i++) {
        if (addrBytes4[i] != h[i]) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
