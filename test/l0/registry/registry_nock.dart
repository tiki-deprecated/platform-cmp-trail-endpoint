/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:nock/nock.dart';
import 'package:test/expect.dart';
import 'package:tiki_sdk_dart/l0/registry/registry_repository.dart';

class RegistryNock {
  static const String address1 = 'uuAT_XIBZlerT0JWxk9NxvXqeJ4VFfwqHL5E8gB8Kug';
  static const String address2 = 'o-rATfYsgtW8EKcOdFkolnJBqQxHHIWcXt0gkdRlqYg';
  static const String address3 = 'JQWqDhqTG6uKP-jSBfZeuLbS2DV4wqP33LOpeYZG55Y';
  static const String signKey =
      'MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCYZJUg355kHo8uhKlB2UOTLrtMbJVMKYe7fqMhH3bka6tDo8zZuEE2SzbwuycHU5X0UPiA0amPF2zhGAJAGvGVs20hWsD+2HYtdO9kL98cGPXUyqKBd7Izqq34IWWTZGOcWw7yiViJ4XfdlsOPIIE4mko8+uv8OyiuQSoCsiv9opYP0d4CYFp9eYCaznxY0NRO15FAoHiq1nqfbzTKbGjgoW2Ug44ZzMp4pPBrDXvIvXrUfJhwdAtOzwEFN6tAd8KS3/Sg+C2mQ42Um3QsngG9IA8Cf4MaG9Qy9KKZcUiMKj4gPNARzfX37hHCr7kW1A0cJBGQhlGKSTVOp6PlGTiFAgMBAAECggEADH/niYA+DilBhkfEWE3ZUJe7LiwT3ODlLLhY6g0aI+c+73fehBcsZicqNPms3Fl7ScRgdbR8y2tY92eQO7DaEvTaJSu7+8tGejkGr7mLe9MCSvdp9+OY/srnpRwcKEhKMVd4tOUWGY0gV1EX7kP0xW9GWpUcSR6TGiPnLbxuhkmwx1jY1arvn1OBeACTJHVTobi3tRqWevXilU9q1OY5k6WGrvL5blbdgTTvswK2ACeVY5q2MUzgUuTarznhKDSKR/8/aRANwHoxJF18jOTVgINYIIqL7KaAv6jHGRsMqs63rAuOSj8Dl2W05XBsU/LHo40+eMBZPBORsa+uGL+CKwKBgQDNNxM2f7YTPnOQ4f3edm6n+9MyL6jNHHraARI/uPdvnumhb/+b//3b3JQhGBgV8MheqFqVAxrt/RW8Jr/KwQE4WMVNQ1XSL8+F5b4o+4xhilIU8nyhZ+D9MxEYYOfN0IIXbWdNPhmrH06dpAbRLdIPlygLRmYNOz7FoAgwp/hEVwKBgQC+GxQI2iL3WGaAthMRgzWd+bTX8XNSC6NMdWgqdnzI+P30dQPwg6lE8pOWoX51KTL4ioSOWCDptNHWyJUNSKOXp68yIDOeIlQ8U/4iViAbt5wn7e2qwM5bvgY4q9ORjS6Lq/ELllOyJU5ohDm3VyHGWw69Toounq0zTqTLWHvAgwKBgD+Mqad73x+QfGtGgL6OgHAG3P0yoxx5kFXIdSVEm2N2m7UBoO9nU+7tHPYupu7MdNBTZFG293TxpfRxL32TTVRssRTfIEmJwsMdRUkdtPhTxF12RkAZkiP213lsMPyccFze5VmXPI2wkUDiFbZbcSygy6bKMzovuZ2rlD21Fn3bAoGBAKEUuq4hf51MB1aqcI/XONhJ3IVZbpinic/gb8oDKgr0h+LaP+NM/GGSlaH95vQJW8ojPNyMKh88+szemwVtdkirahS0Gmi0t+GCXgTkK0KxGpzuywJzaqdr5UOhvJxJH5Zzs8RYtURuvfhriagjKVg0kdGwOf/0rdeanKI8sGdXAoGBAIHI5KfeYvo8hy20nyIJm5kIOQeLkQqhPPdEOXk3ymvRzjBMgcYOLEI4yABbZTtuAqbTgklEWzm3K/omFKSIkodmh/bKeSQlTfR9B+4vtAeyIyf3vlwX1MhAwJ5hP8xS5On1E0wf3H55H9pLPaOaVxdksxf2AWvDeV49Sud3wQbe';

  Interceptor get postInterceptor =>
      nock(RegistryRepository.url).post(RegistryRepository.path, {
        "id": const TypeMatcher<String>(),
        "address": const TypeMatcher<String>()
      })
        ..headers({
          "content-type": startsWith("application/json"),
          "accept": "application/json",
          "authorization": startsWith("Bearer "),
          "x-address-signature": anything,
          "x-customer-authorization": startsWith("Bearer "),
        })
        ..reply(
          200,
          jsonEncode({
            'signKey': signKey,
            'addresses': [address1]
          }),
        );

  Interceptor get getInterceptor =>
      nock(RegistryRepository.url).get(startsWith(RegistryRepository.path))
        ..headers({
          "content-type": "application/json",
          "accept": "application/json",
          "authorization": startsWith("Bearer "),
          "x-address-signature": anything,
          "x-customer-authorization": startsWith("Bearer "),
        })
        ..reply(
          200,
          jsonEncode({
            'signKey': signKey,
            'addresses': [address1, address2, address3]
          }),
        );
}
