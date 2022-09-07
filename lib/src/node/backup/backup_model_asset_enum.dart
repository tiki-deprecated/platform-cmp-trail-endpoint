enum BackupModelAssetEnum {
  pubkey('pubkey', 0),
  block('block', 1);

  const BackupModelAssetEnum(this.value, this.byte);

  final String value;

  final int byte;
}
