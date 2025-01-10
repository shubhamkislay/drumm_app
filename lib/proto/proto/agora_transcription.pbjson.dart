//
//  Generated code. Do not modify.
//  source: proto/agora_transcription.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use textDescriptor instead')
const Text$json = {
  '1': 'Text',
  '2': [
    {'1': 'vendor', '3': 1, '4': 1, '5': 5, '10': 'vendor'},
    {'1': 'version', '3': 2, '4': 1, '5': 5, '10': 'version'},
    {'1': 'seqnum', '3': 3, '4': 1, '5': 5, '10': 'seqnum'},
    {'1': 'uid', '3': 4, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'flag', '3': 5, '4': 1, '5': 5, '10': 'flag'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'lang', '3': 7, '4': 1, '5': 5, '10': 'lang'},
    {'1': 'starttime', '3': 8, '4': 1, '5': 5, '10': 'starttime'},
    {'1': 'offtime', '3': 9, '4': 1, '5': 5, '10': 'offtime'},
    {'1': 'words', '3': 10, '4': 3, '5': 11, '6': '.drumm_app.Word', '10': 'words'},
    {'1': 'end_of_segment', '3': 11, '4': 1, '5': 8, '10': 'endOfSegment'},
    {'1': 'duration_ms', '3': 12, '4': 1, '5': 5, '10': 'durationMs'},
    {'1': 'data_type', '3': 13, '4': 1, '5': 9, '10': 'dataType'},
    {'1': 'trans', '3': 14, '4': 3, '5': 11, '6': '.drumm_app.Translation', '10': 'trans'},
    {'1': 'culture', '3': 15, '4': 1, '5': 9, '10': 'culture'},
    {'1': 'text_ts', '3': 16, '4': 1, '5': 3, '10': 'textTs'},
  ],
};

/// Descriptor for `Text`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textDescriptor = $convert.base64Decode(
    'CgRUZXh0EhYKBnZlbmRvchgBIAEoBVIGdmVuZG9yEhgKB3ZlcnNpb24YAiABKAVSB3ZlcnNpb2'
    '4SFgoGc2VxbnVtGAMgASgFUgZzZXFudW0SEAoDdWlkGAQgASgDUgN1aWQSEgoEZmxhZxgFIAEo'
    'BVIEZmxhZxISCgR0aW1lGAYgASgDUgR0aW1lEhIKBGxhbmcYByABKAVSBGxhbmcSHAoJc3Rhcn'
    'R0aW1lGAggASgFUglzdGFydHRpbWUSGAoHb2ZmdGltZRgJIAEoBVIHb2ZmdGltZRIlCgV3b3Jk'
    'cxgKIAMoCzIPLmRydW1tX2FwcC5Xb3JkUgV3b3JkcxIkCg5lbmRfb2Zfc2VnbWVudBgLIAEoCF'
    'IMZW5kT2ZTZWdtZW50Eh8KC2R1cmF0aW9uX21zGAwgASgFUgpkdXJhdGlvbk1zEhsKCWRhdGFf'
    'dHlwZRgNIAEoCVIIZGF0YVR5cGUSLAoFdHJhbnMYDiADKAsyFi5kcnVtbV9hcHAuVHJhbnNsYX'
    'Rpb25SBXRyYW5zEhgKB2N1bHR1cmUYDyABKAlSB2N1bHR1cmUSFwoHdGV4dF90cxgQIAEoA1IG'
    'dGV4dFRz');

@$core.Deprecated('Use wordDescriptor instead')
const Word$json = {
  '1': 'Word',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'start_ms', '3': 2, '4': 1, '5': 5, '10': 'startMs'},
    {'1': 'duration_ms', '3': 3, '4': 1, '5': 5, '10': 'durationMs'},
    {'1': 'is_final', '3': 4, '4': 1, '5': 8, '10': 'isFinal'},
    {'1': 'confidence', '3': 5, '4': 1, '5': 1, '10': 'confidence'},
  ],
};

/// Descriptor for `Word`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wordDescriptor = $convert.base64Decode(
    'CgRXb3JkEhIKBHRleHQYASABKAlSBHRleHQSGQoIc3RhcnRfbXMYAiABKAVSB3N0YXJ0TXMSHw'
    'oLZHVyYXRpb25fbXMYAyABKAVSCmR1cmF0aW9uTXMSGQoIaXNfZmluYWwYBCABKAhSB2lzRmlu'
    'YWwSHgoKY29uZmlkZW5jZRgFIAEoAVIKY29uZmlkZW5jZQ==');

@$core.Deprecated('Use translationDescriptor instead')
const Translation$json = {
  '1': 'Translation',
  '2': [
    {'1': 'is_final', '3': 1, '4': 1, '5': 8, '10': 'isFinal'},
    {'1': 'lang', '3': 2, '4': 1, '5': 9, '10': 'lang'},
    {'1': 'texts', '3': 3, '4': 3, '5': 9, '10': 'texts'},
  ],
};

/// Descriptor for `Translation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translationDescriptor = $convert.base64Decode(
    'CgtUcmFuc2xhdGlvbhIZCghpc19maW5hbBgBIAEoCFIHaXNGaW5hbBISCgRsYW5nGAIgASgJUg'
    'RsYW5nEhQKBXRleHRzGAMgAygJUgV0ZXh0cw==');

