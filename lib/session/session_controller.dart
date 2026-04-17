import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SessionController extends GetxController {
  static SessionController get instance => Get.find<SessionController>();

  final _box = GetStorage();

  final RxInt userId = 0.obs;
  final RxString name = "".obs;
  final RxString email = "".obs;
  final RxnInt levelId = RxnInt();
  final RxString profileImageBase64 = "".obs;

  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSession();
  }

  String _cleanBase64(String b64) {
    if (b64.trim().isEmpty) return "";
    final s = b64.trim();
    final idx = s.indexOf("base64,");
    if (idx != -1) return s.substring(idx + "base64,".length).trim();
    return s;
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse("${v ?? ""}") ?? 0;
  }

  void createSessionFromUser(Map<String, dynamic> user) {
    print("🟦 CREATE SESSION FROM USER: $user");

    // ✅ support both keys: id / user_id
    final idVal = user["id"] ?? user["user_id"];
    final nameVal = user["name"];
    final emailVal = user["email"];
    final levelVal = user["level_id"];

    final imgVal = user["image"] ?? user["profile_image"] ?? user["avatar"] ?? "";

    userId.value = _toInt(idVal);
    name.value = (nameVal ?? "").toString();
    email.value = (emailVal ?? "").toString();
    levelId.value = (levelVal == null) ? null : _toInt(levelVal);

    profileImageBase64.value = _cleanBase64((imgVal ?? "").toString());

    isLoggedIn.value = userId.value != 0;

    // ✅ persist
    _box.write("userId", userId.value);
    _box.write("name", name.value);
    _box.write("email", email.value);
    _box.write("levelId", levelId.value);
    _box.write("profileImageBase64", profileImageBase64.value);
    _box.write("isLoggedIn", isLoggedIn.value);

    print("✅ SESSION SAVED -> loggedIn=${isLoggedIn.value}, id=${userId.value}");
  }

  void loadSession() {
    final savedLoggedIn = _box.read("isLoggedIn") == true;

    userId.value = _box.read("userId") ?? 0;
    name.value = _box.read("name") ?? "";
    email.value = _box.read("email") ?? "";
    levelId.value = _box.read("levelId");
    profileImageBase64.value = _box.read("profileImageBase64") ?? "";

    isLoggedIn.value = savedLoggedIn && userId.value != 0;

    print("🟩 SESSION LOADED -> loggedIn=${isLoggedIn.value}, id=${userId.value}");
  }

  void clearSession() {
    print("🟥 CLEAR SESSION");

    userId.value = 0;
    name.value = "";
    email.value = "";
    levelId.value = null;
    profileImageBase64.value = "";
    isLoggedIn.value = false;

    _box.remove("userId");
    _box.remove("name");
    _box.remove("email");
    _box.remove("levelId");
    _box.remove("profileImageBase64");
    _box.remove("isLoggedIn");
  }
}
