// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class RecognitionEmbedding {
  Rect location;
  List<double> embedding;

  RecognitionEmbedding({
    required this.location,
    required this.embedding,
  });
}
