class ApiUrl {
  // User
  static const String nickNameUpdate = "/api/user/name";
  static const String profileImageUpdate = "/api/user/image/profile";
  static const String backgroundImageUpdate = "/api/user/image/background";
  static const String imageUpload = "/api/user/";
  static const String myInfo = "/api/user/myinfo";
  static const String allUsers = "/api/user/allusers";
  static const String specificusers = "/api/user/specificusers";

  // Auth
  static const String googleLogin = "/api/auth/google/login";
  static const String kakaoLogin = "/api/auth/kakao/login";
  static const String naverLogin = "/api/auth/naver/login";
  static const String refresh = "/api/auth/refresh";
  static const String login = "/api/auth/logout";
  static const String withDraw = "/api/auth/withdraw";

  // Location
  static const String getCode = "/api/common/location/getCode";
  static const String getNameByCodes = "/api/common/location/getnamebycodes";
  static const String getNameByCode = "/api/common/location/getnamebycode/";
  static const String getGrid = "/api/common/location/getgrid/";
  static const String freqDisrict = "/api/common/location/freqdistrict";
  static const String locationDefault = "/api/common/location/default";
  static const String sameGrid = "/api/common/location/samegrid/";

  // Weather
  static const String insert = "/api/common/weather/insert";
  static const String datas = "/api/common/weather/datas";

  // Neighborhood Weather
  static const String weather = "/api/posting/weather";
  static const String weatherCount = "/api/posting/weather/count";
  static const String weatherDelete = "/api/posting/weather/";

  // Upload
  static const String posting = "/api/posting/post";
  static const String report = "/api/posting/post/report";
  static const String like = "/api/posting/post/like";
  static const String posts = "/api/posting/posts";
  static const String post = "/api/posting/post/";
  static const String test = "/api/posting/test";
}
