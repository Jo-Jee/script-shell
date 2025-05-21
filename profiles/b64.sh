# base64 인코딩
b64() {
  echo -n "$1" | base64
}

# base64 디코딩
b64d() {
  echo "$1" | base64 --decode
}