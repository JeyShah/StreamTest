String convertFlvToM3u8(String url) {
  if (url.toLowerCase().endsWith('.flv')) {
    return url.replaceAll(RegExp(r'\.flv$', caseSensitive: false), '.m3u8');
  }
  // If it's already m3u8 or another format, just return as is
  return url;
}