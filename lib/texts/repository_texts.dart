class RepositoryTexts {
  const RepositoryTexts._();

  static const storageLocationsTable = 'storage_locations';
  static const slotContentsTable = 'location_slot_contents';
  static const slotMergesTable = 'location_slot_merges';

  static const orderByUpdatedAtIdDesc = 'updated_at DESC, id DESC';
  static const updateMissingIdError =
      'Storage location ID is required for updates.';

  static const idColumn = 'id';
  static const locationCodeColumn = 'location_code';
  static const slotTypeColumn = 'slot_type';
  static const containerLabelColumn = 'container_label';
  static const slotLabelColumn = 'slot_label';
  static const firstSlotLabelColumn = 'first_slot_label';
  static const secondSlotLabelColumn = 'second_slot_label';
  static const contentsColumn = 'contents';
  static const updatedAtColumn = 'updated_at';

  static const separatorDash = '-';
  static const separatorPipe = '|';
  static const empty = '';

  static const whereIdEquals = 'id = ?';
  static const whereLocationCodeEquals = 'location_code = ?';
  static const whereLocationCodeEqualsAndIdNotEquals =
      'location_code = ? AND id != ?';
  static const whereLocationCodeEqualsOrLike =
      'location_code = ? OR location_code LIKE ?';
  static const whereLocationCodeLike = 'location_code LIKE ?';

  static const whereSlotContentByLocationAndSlot =
      'location_code = ? AND slot_type = ? AND container_label = ? AND slot_label = ?';

  static const whereSlotMergeByLocationAndPair =
      'location_code = ? AND slot_type = ? AND container_label = ? AND first_slot_label = ? AND second_slot_label = ?';

  static String likePatternForIdentifier(String baseIdentifier) {
    return '$baseIdentifier$separatorDash%';
  }

  static String startsWithIdentifierPrefix(String baseIdentifier) {
    return '$baseIdentifier$separatorDash';
  }

  static String quickNameLikePattern(String storageBase) {
    return 'QN-$storageBase-%';
  }

  static RegExp quickNamePattern(String storageBase) {
    return RegExp('^QN-${RegExp.escape(storageBase)}-(\\d+)-ST-');
  }

  static String containerKey(
    String locationCode,
    String slotType,
    String containerLabel,
  ) {
    return '$locationCode$separatorPipe$slotType$separatorPipe$containerLabel';
  }

  static String pairKey(String first, String second) {
    return '$first$separatorPipe$second';
  }
}
