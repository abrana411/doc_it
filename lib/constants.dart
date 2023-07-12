import 'package:flutter/material.dart';

const bg1Color = Colors.white;
const txt1Color = Colors.black;
const bt1Color = Colors.blue;

// const initialUrl = "http://10.0.2.2:3001";
const initialUrl = "http://192.168.0.101:3001";

BoxDecoration decoration = BoxDecoration(
  color: Colors.grey.shade300,
  boxShadow: [
    BoxShadow(
        color: Colors.grey.shade900,
        offset: const Offset(4.0, 4.0),
        blurRadius: 15.0,
        spreadRadius: 1.0),
    BoxShadow(
        color: Colors.grey.shade400,
        offset: const Offset(-4.0, -4.0),
        blurRadius: 15.0,
        spreadRadius: 1.0),
  ],
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.grey.shade500,
      Colors.grey.shade600,
      Colors.grey.shade700,
      Colors.grey.shade800,
    ],
    stops: const [0.1, 0.3, 0.6, 0.8],
  ),
);
