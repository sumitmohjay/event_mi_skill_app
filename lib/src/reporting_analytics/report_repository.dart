import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'report_model.dart';

class ReportRepository {
  // Mock data - in a real app, this would come from an API
  final List<EventReport> _reports = [
    EventReport(
      id: '1',
      eventName: 'Tech Conference 2023',
      date: DateTime(2023, 10, 15),
      totalAttendees: 250,
      checkedInAttendees: 210,
      attendanceData: List.generate(10, (index) => {
        'name': 'Attendee ${index + 1}',
        'email': 'attendee${index + 1}@example.com',
        'checkedIn': index < 8, // First 8 are checked in
        'checkInTime': index < 8 
            ? DateTime(2023, 10, 15, 9 + index ~/ 2, (index % 2) * 30)
            : null,
      }),
    ),
    // Add more sample reports as needed
  ];

  Future<List<EventReport>> getReports() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _reports;
  }

  Future<EventReport?> getReportById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }

  // Generate Excel report
  Future<Uint8List> generateExcelReport(EventReport report) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    
    // Add headers
    sheet.appendRow(['Event Name', 'Date', 'Total Attendees', 'Checked In', 'Check-in Rate']);
    
    // Add data
    sheet.appendRow([
      report.eventName,
      report.date.toString().split(' ')[0],
      report.totalAttendees,
      report.checkedInAttendees,
      '${report.attendanceRate.toStringAsFixed(1)}%'
    ]);
    
    // Add summary rows
    sheet.appendRow(['']);
    sheet.appendRow(['Summary']);
    sheet.appendRow(['Total Attendees', report.totalAttendees]);
    sheet.appendRow(['Checked In', report.checkedInAttendees]);
    sheet.appendRow(['Attendance Rate', '${report.attendanceRate.toStringAsFixed(1)}%']);

    // Generate the Excel file and convert to Uint8List
    final excelBytes = excel.encode();
    if (excelBytes == null) {
      throw Exception('Failed to generate Excel file');
    }
    return Uint8List.fromList(excelBytes);
  }

  // Generate PDF report
  Future<Uint8List> generatePdfReport(EventReport report) async {
    final pdf = pw.Document();
    
    // Load a font
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text('Event Report: ${report.eventName}')),
          pw.Header(level: 1, child: pw.Text('Attendance Summary')),
          pw.Paragraph(text: 'Date: ${report.date.toString().split(' ')[0]}'),
          pw.Paragraph(text: 'Total Attendees: ${report.totalAttendees}'),
          pw.Paragraph(text: 'Checked In: ${report.checkedInAttendees}'),
          pw.Paragraph(
            text: 'Attendance Rate: ${report.attendanceRate.toStringAsFixed(1)}%',
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Attendance List')),
          pw.Table.fromTextArray(
            headers: ['Name', 'Email', 'Checked In', 'Check-in Time'],
            data: report.attendanceData.map((a) => [
              a['name'],
              a['email'],
              (a['checkedIn'] as bool) ? 'Yes' : 'No',
              a['checkInTime']?.toString() ?? 'N/A',
            ]).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
