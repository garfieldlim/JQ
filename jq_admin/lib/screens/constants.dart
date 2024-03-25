const String baseURL =
    "https://7e6b-2001-b011-d804-8261-d060-7491-2d0a-4491.ngrok-free.app";
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
