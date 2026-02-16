class Appointment {
  final int appointmentId;
  final int providerId;
  final int userId;
  final String date;
  final String time;
  final String reason;
  final String status;
  final String? meetingId;
  final String? providerName;
  final String? userName;
  final String? userEmail;
  final String? serviceName;

  Appointment({
    required this.appointmentId,
    required this.providerId,
    required this.userId,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    this.meetingId,
    this.providerName,
    this.userName,
    this.userEmail,
    this.serviceName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: int.parse(json['appointment_id'].toString()),
      providerId: int.parse(json['provider_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      date: json['date'],
      time: json['time'],
      reason: json['reason'],
      status: json['status'],
      meetingId: json['meeting_id'],
      providerName: json['provider_name'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      serviceName: json['service_name'],
    );
  }
}