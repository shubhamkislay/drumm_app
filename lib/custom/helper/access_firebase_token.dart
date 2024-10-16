import 'package:googleapis_auth/auth_io.dart';

class AccessTokenFirebase {
  static String firebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "drummapp",
          "private_key_id": "188242cc474606711a48e58e2b1f49a6a0eab1b5",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC7r2chZyODEzo0\nZUmLrkf6e8RrGP8WiJpNDXYW9GZI9rBQrqMp2+mBqFe+xTNGw+y+dzfI9Ll3f90t\n+5jtByXeRQyvPfIIVQZQltQqrENV2394QUlAGV0xCrqPIu+FPjk8dizHQYUyWAAu\nRxb/eSz4LKO9dwOqRWvQo6hNkyIv26DvkJGQqQtzC/dE0kKb/DiD1XEm0iHw9bu3\nXukCR3IfGnyq0D4yYUzXCT/0T2DfaAMqEjkHFKddGW0EE2exZBWBNjj00zGl1a2S\noPntfQdtad85USUfjYRJuvyL++jwqebC+ksUkZ7pTcMT2gnQHM1IvwxdjhYQCmb5\n5mJDEzkBAgMBAAECggEABRofwQWkTm6QEC8x8nAvnJp/WJw4iH64h5hSZc25Z1m9\n6aaSsMtNr+ixMHJcyktekN+tqnrFHS+Slhq7IbPmWpJI1c12ujVh/2A3RqzxxGhr\n8Ntg+/MokHIKx+P2rAoIzSkG/vhr8BY6dIeaE2IyV9GCVr7g0JDULUr6ove5R+Da\nEuag81tnUN9uUiHuPUsBKCVCvHraC4avMTrC6GuOBTVLSDaNtbNXHAmMtnYYUiEa\nq9/dC7Lne6rG5Z2LkV4aKolvxLfAQRIFi5Kl46CJ7oIR7lJcsz2XGGb3YXE1IZkW\nNz/omZTaJWntlQ52yqaQi9j498jyXm4FgKH+nW0PwQKBgQDmAnnjrpxeUBaCvHra\nXnGw13R2REpsjmEQZvKCSoNQ0e3jeas0uxkiEAicc57/glBPd0FLRTRgy9R8VN22\nIZiMOD3GjuNxtBygDX4939gF3ig0ahBlZyBy56WQ55qrK1zWHvMQK3uALFTUYL+R\nQuTtO/wmOljhwuQDumukEwupIQKBgQDQ5Jl4npRDRCJ3bJ4D6zSN4nAH73oUucdx\nUath4xF9r5hsnB8hMV4W+63vCg+r/U3nO95Ldr/NNSIMmn18xEONSdqT1rmAFHUK\nvYjoEu+HrF9NzRmtzof68OXTeWcTyT0/3iTDTfdvhNcX0PnkYvT5qr3FPU8+panO\nQD5GZOIz4QKBgHkrYsUELpIsxL8YxeuWB3Su/EZ1kXOAyjeW1Di5QlZoUVcduIit\n6/6azb6F1oQqRV6np3kcuwwnNQhOuQICztdHpZudmMpEpTPYB+JWsvncX/fEzGBv\nJJQD3p/osv1reZu/cDLbhVMvh3zefuzqfalQiXQmFr7QKcihA6XK9sChAoGAYh4u\nFCDwZRQY2F11b0PIQKjOlHugrSGCE7EXvffJHG8hOkquuImWt1bqIPBp4hAtymIt\njOavOrUtVBwwuyz4yeGZwH1ITmfNfgj+yHs0dVa6wTGIUUJETtNeMFHC3+FTWq9+\nNxplEcWkvnQTHHp6tNbFImMk2Lk5pD46whfaxCECgYB6/WKpkIJ59oVsFcKuaFAj\nT7l6hXYGExcwB+52SWXuxWEc0AqjqzLEEEkHN36BkXTsjFdUtn/CEnAdiSD75bKJ\nk/t7X09K6/mMEmJCinJH0v8+eEyPSI3Ri2HC0L3Gg1LsfB16qZEMifxiloC6tKq7\nvJhUmR8W+YNFS5LnU7g9Tw==\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-o7ezt@drummapp.iam.gserviceaccount.com",
          "client_id": "116089565900020100017",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-o7ezt%40drummapp.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [firebaseMessagingScope]);

    //Extract the access token from the credentials.

    final accessToken = client.credentials.accessToken.data;

    return accessToken;
  }
}
