const String baseURL =
    "https://c4a0-2001-b011-d804-acba-2c05-ea1f-2b59-3a4d.ngrok-free.app";
const String postsUrl = '$baseURL/posts';
const String queryURL = '$baseURL/query';
const String updateChatDislikeURL = '$baseURL/update_chat_message_like_dislike';
const String saveChatURL = '$baseURL/save_chat_message';
const String receiveJsonURL = '$baseURL/receive_json';
const String scrapeWebsiteURL = '$baseURL/scrape_website';
const String getDataURL = '$baseURL/get_data/';
const String upsertURL = '$baseURL/upsert';
String getDeleteDataUrl(String selectedPartition, String uuid) {
  return '$baseURL/delete/$selectedPartition/$uuid';
}

String getUpdateDataUrl(String selectedPartition, String uuid) {
  return '$baseURL/update/$selectedPartition/$uuid';
}
