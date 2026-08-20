class AddMaterialIssueNoteRequest {
  const AddMaterialIssueNoteRequest({
    required this.indentTypeId,
    required this.indentId,
    required this.issueNoteNo,
    required this.issueNoteDate,
    required this.materialIssueNoteDetails,
    this.remarks,
  });

  final int indentTypeId;
  final int indentId;
  final String issueNoteNo;
  final DateTime issueNoteDate;
  final String? remarks;
  final List<AddMaterialIssueNoteDetails> materialIssueNoteDetails;

  Map<String, dynamic> toJson() => {
        'indentTypeId': indentTypeId,
        'indentId': indentId,
        'issueNoteNo': issueNoteNo,
        'issueNoteDate': issueNoteDate.toIso8601String(),
        'remarks': remarks,
        'materialIssueNoteDetails': materialIssueNoteDetails
            .map((item) => item.toJson())
            .toList(),
      };
}

class AddMaterialIssueNoteDetails {
  const AddMaterialIssueNoteDetails({
    required this.materialId,
    required this.availableStock,
    required this.indentQty,
    required this.issuedQty,
    required this.remainingQty,
    required this.finalStock,
    this.description,
    this.uomId,
  });

  final int materialId;
  final double availableStock;
  final double indentQty;
  final double issuedQty;
  final double remainingQty;
  final double finalStock;
  final String? description;
  final int? uomId;

  Map<String, dynamic> toJson() => {
        'materialId': materialId,
        'availableStock': availableStock,
        'indentQty': indentQty,
        'issuedQty': issuedQty,
        'remainingQty': remainingQty,
        'finalStock': finalStock,
        'description': description,
        'uomId': uomId,
      };
}
