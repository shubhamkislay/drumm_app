//
//  Generated code. Do not modify.
//  source: proto/agora_transcription.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class ProtoText extends $pb.GeneratedMessage {
  factory ProtoText({
    $core.int? vendor,
    $core.int? version,
    $core.int? seqnum,
    $fixnum.Int64? uid,
    $core.int? flag,
    $fixnum.Int64? time,
    $core.int? lang,
    $core.int? starttime,
    $core.int? offtime,
    $core.Iterable<Word>? words,
    $core.bool? endOfSegment,
    $core.int? durationMs,
    $core.String? dataType,
    $core.Iterable<Translation>? trans,
    $core.String? culture,
    $fixnum.Int64? textTs,
  }) {
    final $result = create();
    if (vendor != null) {
      $result.vendor = vendor;
    }
    if (version != null) {
      $result.version = version;
    }
    if (seqnum != null) {
      $result.seqnum = seqnum;
    }
    if (uid != null) {
      $result.uid = uid;
    }
    if (flag != null) {
      $result.flag = flag;
    }
    if (time != null) {
      $result.time = time;
    }
    if (lang != null) {
      $result.lang = lang;
    }
    if (starttime != null) {
      $result.starttime = starttime;
    }
    if (offtime != null) {
      $result.offtime = offtime;
    }
    if (words != null) {
      $result.words.addAll(words);
    }
    if (endOfSegment != null) {
      $result.endOfSegment = endOfSegment;
    }
    if (durationMs != null) {
      $result.durationMs = durationMs;
    }
    if (dataType != null) {
      $result.dataType = dataType;
    }
    if (trans != null) {
      $result.trans.addAll(trans);
    }
    if (culture != null) {
      $result.culture = culture;
    }
    if (textTs != null) {
      $result.textTs = textTs;
    }
    return $result;
  }
  ProtoText._() : super();
  factory ProtoText.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProtoText.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Text', package: const $pb.PackageName(_omitMessageNames ? '' : 'drumm_app'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'vendor', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'seqnum', $pb.PbFieldType.O3)
    ..aInt64(4, _omitFieldNames ? '' : 'uid')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'flag', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'time')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'lang', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'starttime', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'offtime', $pb.PbFieldType.O3)
    ..pc<Word>(10, _omitFieldNames ? '' : 'words', $pb.PbFieldType.PM, subBuilder: Word.create)
    ..aOB(11, _omitFieldNames ? '' : 'endOfSegment')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'durationMs', $pb.PbFieldType.O3)
    ..aOS(13, _omitFieldNames ? '' : 'dataType')
    ..pc<Translation>(14, _omitFieldNames ? '' : 'trans', $pb.PbFieldType.PM, subBuilder: Translation.create)
    ..aOS(15, _omitFieldNames ? '' : 'culture')
    ..aInt64(16, _omitFieldNames ? '' : 'textTs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProtoText clone() => ProtoText()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProtoText copyWith(void Function(ProtoText) updates) => super.copyWith((message) => updates(message as ProtoText)) as ProtoText;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProtoText create() => ProtoText._();
  ProtoText createEmptyInstance() => create();
  static $pb.PbList<ProtoText> createRepeated() => $pb.PbList<ProtoText>();
  @$core.pragma('dart2js:noInline')
  static ProtoText getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProtoText>(create);
  static ProtoText? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get vendor => $_getIZ(0);
  @$pb.TagNumber(1)
  set vendor($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVendor() => $_has(0);
  @$pb.TagNumber(1)
  void clearVendor() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get seqnum => $_getIZ(2);
  @$pb.TagNumber(3)
  set seqnum($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSeqnum() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeqnum() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get uid => $_getI64(3);
  @$pb.TagNumber(4)
  set uid($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUid() => $_has(3);
  @$pb.TagNumber(4)
  void clearUid() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get flag => $_getIZ(4);
  @$pb.TagNumber(5)
  set flag($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFlag() => $_has(4);
  @$pb.TagNumber(5)
  void clearFlag() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get lang => $_getIZ(6);
  @$pb.TagNumber(7)
  set lang($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLang() => $_has(6);
  @$pb.TagNumber(7)
  void clearLang() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get starttime => $_getIZ(7);
  @$pb.TagNumber(8)
  set starttime($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasStarttime() => $_has(7);
  @$pb.TagNumber(8)
  void clearStarttime() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get offtime => $_getIZ(8);
  @$pb.TagNumber(9)
  set offtime($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasOfftime() => $_has(8);
  @$pb.TagNumber(9)
  void clearOfftime() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<Word> get words => $_getList(9);

  @$pb.TagNumber(11)
  $core.bool get endOfSegment => $_getBF(10);
  @$pb.TagNumber(11)
  set endOfSegment($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasEndOfSegment() => $_has(10);
  @$pb.TagNumber(11)
  void clearEndOfSegment() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get durationMs => $_getIZ(11);
  @$pb.TagNumber(12)
  set durationMs($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasDurationMs() => $_has(11);
  @$pb.TagNumber(12)
  void clearDurationMs() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get dataType => $_getSZ(12);
  @$pb.TagNumber(13)
  set dataType($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDataType() => $_has(12);
  @$pb.TagNumber(13)
  void clearDataType() => clearField(13);

  @$pb.TagNumber(14)
  $core.List<Translation> get trans => $_getList(13);

  @$pb.TagNumber(15)
  $core.String get culture => $_getSZ(14);
  @$pb.TagNumber(15)
  set culture($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasCulture() => $_has(14);
  @$pb.TagNumber(15)
  void clearCulture() => clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get textTs => $_getI64(15);
  @$pb.TagNumber(16)
  set textTs($fixnum.Int64 v) { $_setInt64(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasTextTs() => $_has(15);
  @$pb.TagNumber(16)
  void clearTextTs() => clearField(16);
}

class Word extends $pb.GeneratedMessage {
  factory Word({
    $core.String? text,
    $core.int? startMs,
    $core.int? durationMs,
    $core.bool? isFinal,
    $core.double? confidence,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    if (startMs != null) {
      $result.startMs = startMs;
    }
    if (durationMs != null) {
      $result.durationMs = durationMs;
    }
    if (isFinal != null) {
      $result.isFinal = isFinal;
    }
    if (confidence != null) {
      $result.confidence = confidence;
    }
    return $result;
  }
  Word._() : super();
  factory Word.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Word.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Word', package: const $pb.PackageName(_omitMessageNames ? '' : 'drumm_app'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'startMs', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'durationMs', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'isFinal')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'confidence', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Word clone() => Word()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Word copyWith(void Function(Word) updates) => super.copyWith((message) => updates(message as Word)) as Word;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Word create() => Word._();
  Word createEmptyInstance() => create();
  static $pb.PbList<Word> createRepeated() => $pb.PbList<Word>();
  @$core.pragma('dart2js:noInline')
  static Word getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Word>(create);
  static Word? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get startMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set startMs($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartMs() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get durationMs => $_getIZ(2);
  @$pb.TagNumber(3)
  set durationMs($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDurationMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationMs() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isFinal => $_getBF(3);
  @$pb.TagNumber(4)
  set isFinal($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsFinal() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsFinal() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get confidence => $_getN(4);
  @$pb.TagNumber(5)
  set confidence($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfidence() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfidence() => clearField(5);
}

class Translation extends $pb.GeneratedMessage {
  factory Translation({
    $core.bool? isFinal,
    $core.String? lang,
    $core.Iterable<$core.String>? texts,
  }) {
    final $result = create();
    if (isFinal != null) {
      $result.isFinal = isFinal;
    }
    if (lang != null) {
      $result.lang = lang;
    }
    if (texts != null) {
      $result.texts.addAll(texts);
    }
    return $result;
  }
  Translation._() : super();
  factory Translation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Translation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Translation', package: const $pb.PackageName(_omitMessageNames ? '' : 'drumm_app'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isFinal')
    ..aOS(2, _omitFieldNames ? '' : 'lang')
    ..pPS(3, _omitFieldNames ? '' : 'texts')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Translation clone() => Translation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Translation copyWith(void Function(Translation) updates) => super.copyWith((message) => updates(message as Translation)) as Translation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Translation create() => Translation._();
  Translation createEmptyInstance() => create();
  static $pb.PbList<Translation> createRepeated() => $pb.PbList<Translation>();
  @$core.pragma('dart2js:noInline')
  static Translation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Translation>(create);
  static Translation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isFinal => $_getBF(0);
  @$pb.TagNumber(1)
  set isFinal($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsFinal() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsFinal() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get lang => $_getSZ(1);
  @$pb.TagNumber(2)
  set lang($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLang() => $_has(1);
  @$pb.TagNumber(2)
  void clearLang() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get texts => $_getList(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
