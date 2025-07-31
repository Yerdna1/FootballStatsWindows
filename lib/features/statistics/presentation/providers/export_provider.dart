import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../../data/models/statistics_filter_model.dart';
import '../../data/models/chart_data_model.dart';
import 'statistics_provider.dart';
import 'chart_data_provider.dart';

final logger = Logger();

// Export State
class ExportState {
  final bool isExporting;
  final String? error;
  final String? lastExportPath;
  final ExportProgress? progress;

  const ExportState({
    this.isExporting = false,
    this.error,
    this.lastExportPath,
    this.progress,
  });

  ExportState copyWith({
    bool? isExporting,
    String? error,
    String? lastExportPath,
    ExportProgress? progress,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      error: error,
      lastExportPath: lastExportPath ?? this.lastExportPath,
      progress: progress ?? this.progress,
    );
  }
}

class ExportProgress {
  final String currentTask;
  final double percentage;
  final int currentStep;
  final int totalSteps;

  const ExportProgress({
    required this.currentTask,
    required this.percentage,
    required this.currentStep,
    required this.totalSteps,
  });
}

// Export Notifier
class ExportNotifier extends StateNotifier<ExportState> {
  ExportNotifier() : super(const ExportState());

  Future<String?> exportData({
    required ExportConfigModel config,
    required StatisticsState statisticsData,
    required Map<ChartDataType, ChartDataModel> chartData,
  }) async {
    if (state.isExporting) return null;

    state = state.copyWith(isExporting: true, error: null);

    try {
      switch (config.format) {
        case ExportFormat.csv:
          return await _exportToCsv(config, statisticsData, chartData);
        case ExportFormat.pdf:
          return await _exportToPdf(config, statisticsData, chartData);
        case ExportFormat.json:
          return await _exportToJson(config, statisticsData, chartData);
        case ExportFormat.excel:
          return await _exportToExcel(config, statisticsData, chartData);
      }
    } catch (e, stack) {
      logger.e('Export failed: $e', error: e, stackTrace: stack);
      state = state.copyWith(
        isExporting: false,
        error: 'Export failed: ${e.toString()}',
      );
      return null;
    } finally {
      if (state.isExporting) {
        state = state.copyWith(isExporting: false);
      }
    }
  }

  Future<String> _exportToCsv(
    ExportConfigModel config,
    StatisticsState statisticsData,
    Map<ChartDataType, ChartDataModel> chartData,
  ) async {
    _updateProgress('Preparing CSV data...', 0.1, 1, 4);

    final directory = await getApplicationDocumentsDirectory();
    final fileName = config.fileName ?? 'football_statistics_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');

    final csvData = <List<dynamic>>[];

    // Add header
    csvData.add([
      'Export Generated',
      DateTime.now().toIso8601String(),
    ]);
    csvData.add([]);

    if (config.includeStatistics && config.dataType != ExportDataType.charts) {
      _updateProgress('Processing team statistics...', 0.3, 2, 4);
      
      // Team Statistics Header
      csvData.add(['TEAM STATISTICS']);
      csvData.add([
        'Team Name',
        'League',
        'Matches Played',
        'Wins',
        'Draws',
        'Losses',
        'Points',
        'Goals Scored',
        'Goals Conceded',
        'Goal Difference',
        'Clean Sheets',
        'Win %',
        'Form Rating',
        'Overall Rating',
      ]);

      // Team Statistics Data
      for (final stat in statisticsData.teamStatistics) {
        csvData.add([
          stat.entityName,
          stat.competition,
          stat.matchStats.played,
          stat.matchStats.won,
          stat.matchStats.drawn,
          stat.matchStats.lost,
          stat.matchStats.points,
          stat.goalStats.goalsScored,
          stat.goalStats.goalsConceded,
          stat.goalStats.goalDifference,
          stat.matchStats.cleanSheets,
          stat.matchStats.winPercentage.toStringAsFixed(1),
          stat.formRating.toStringAsFixed(1),
          stat.overallRating.toStringAsFixed(1),
        ]);
      }
      csvData.add([]);
    }

    if (config.includeCharts && config.dataType != ExportDataType.statistics) {
      _updateProgress('Processing chart data...', 0.6, 3, 4);

      for (final entry in chartData.entries) {
        final chartType = entry.key;
        final chart = entry.value;

        if (config.selectedCharts.isNotEmpty && 
            !config.selectedCharts.contains(chartType.name)) {
          continue;
        }

        csvData.add(['CHART DATA - ${chart.title.toUpperCase()}']);
        
        if (chart.series.isNotEmpty) {
          // Headers
          final headers = ['Label'];
          headers.addAll(chart.series.map((s) => s.name));
          csvData.add(headers);

          // Data rows
          final maxDataLength = chart.series.map((s) => s.data.length).reduce((a, b) => a > b ? a : b);
          
          for (int i = 0; i < maxDataLength; i++) {
            final row = <dynamic>[];
            
            // Label
            if (i < chart.labels.length) {
              row.add(chart.labels[i]);
            } else if (chart.series.isNotEmpty && i < chart.series.first.data.length) {
              row.add(chart.series.first.data[i].label);
            } else {
              row.add('Data Point ${i + 1}');
            }

            // Values
            for (final series in chart.series) {
              if (i < series.data.length) {
                row.add(series.data[i].value);
              } else {
                row.add('');
              }
            }
            
            csvData.add(row);
          }
        }
        csvData.add([]);
      }
    }

    _updateProgress('Writing CSV file...', 0.9, 4, 4);

    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);

    state = state.copyWith(lastExportPath: file.path);
    return file.path;
  }

  Future<String> _exportToPdf(
    ExportConfigModel config,
    StatisticsState statisticsData,
    Map<ChartDataType, ChartDataModel> chartData,
  ) async {
    _updateProgress('Creating PDF document...', 0.1, 1, 5);

    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final fileName = config.fileName ?? 'football_statistics_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');

    // Title Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  config.title ?? 'Football Statistics Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              if (config.description != null) ...[
                pw.Text(config.description!, style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 20),
              ],
              pw.Text('Generated: ${DateTime.now().toString().split('.')[0]}'),
              pw.Text('Export Date: ${config.dateGenerated?.toString().split('.')[0] ?? 'N/A'}'),
              pw.SizedBox(height: 40),
              pw.Text('Report Contents:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              if (config.includeStatistics) pw.Text('• Team Statistics'),
              if (config.includeCharts) pw.Text('• Charts and Visualizations'),
              if (config.includeFilters) pw.Text('• Applied Filters'),
            ],
          );
        },
      ),
    );

    if (config.includeStatistics && config.dataType != ExportDataType.charts) {
      _updateProgress('Adding statistics to PDF...', 0.3, 2, 5);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              children: [
                pw.Header(
                  level: 1,
                  child: pw.Text('Team Statistics'),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Team', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Points', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Goals', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Win %', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rating', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...statisticsData.teamStatistics.take(15).map((stat) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(stat.entityName),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(stat.matchStats.points.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${stat.goalStats.goalsScored}/${stat.goalStats.goalsConceded}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${stat.matchStats.winPercentage.toStringAsFixed(1)}%'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(stat.overallRating.toStringAsFixed(1)),
                        ),
                      ],
                    )),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    _updateProgress('Finalizing PDF...', 0.8, 4, 5);

    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    _updateProgress('PDF export completed', 1.0, 5, 5);
    state = state.copyWith(lastExportPath: file.path);
    return file.path;
  }

  Future<String> _exportToJson(
    ExportConfigModel config,
    StatisticsState statisticsData,
    Map<ChartDataType, ChartDataModel> chartData,
  ) async {
    _updateProgress('Preparing JSON data...', 0.1, 1, 3);

    final directory = await getApplicationDocumentsDirectory();
    final fileName = config.fileName ?? 'football_statistics_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    final exportData = <String, dynamic>{
      'metadata': {
        'title': config.title ?? 'Football Statistics Export',
        'description': config.description,
        'exportDate': DateTime.now().toIso8601String(),
        'generatedBy': 'Football Stats App',
      },
    };

    _updateProgress('Processing statistics data...', 0.4, 2, 3);

    if (config.includeStatistics && config.dataType != ExportDataType.charts) {
      exportData['statistics'] = {
        'teamStatistics': statisticsData.teamStatistics.map((stat) => stat.toJson()).toList(),
        'teamForms': statisticsData.teamForms.map((form) => form.toJson()).toList(),
        'standings': statisticsData.standings.map((standing) => standing.toJson()).toList(),
        'summary': {
          'totalTeams': statisticsData.teamStatistics.length,
          'lastUpdated': statisticsData.lastUpdated?.toIso8601String(),
        },
      };
    }

    if (config.includeCharts && config.dataType != ExportDataType.statistics) {
      exportData['charts'] = {};
      for (final entry in chartData.entries) {
        final chartType = entry.key;
        final chart = entry.value;
        
        if (config.selectedCharts.isNotEmpty && 
            !config.selectedCharts.contains(chartType.name)) {
          continue;
        }
        
        exportData['charts'][chartType.name] = chart.toJson();
      }
    }

    _updateProgress('Writing JSON file...', 0.8, 3, 3);

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    await file.writeAsString(jsonString);

    state = state.copyWith(lastExportPath: file.path);
    return file.path;
  }

  Future<String> _exportToExcel(
    ExportConfigModel config,
    StatisticsState statisticsData,
    Map<ChartDataType, ChartDataModel> chartData,
  ) async {
    // For now, export as CSV (Excel support would require additional package)
    // This is a placeholder for future Excel implementation
    return await _exportToCsv(config, statisticsData, chartData);
  }

  void _updateProgress(String task, double percentage, int step, int totalSteps) {
    state = state.copyWith(
      progress: ExportProgress(
        currentTask: task,
        percentage: percentage,
        currentStep: step,
        totalSteps: totalSteps,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ExportState();
  }
}

// Export Utilities
class ExportUtils {
  static String generateFileName(ExportFormat format, {String? prefix}) {
    final timestamp = DateTime.now();
    final dateStr = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}';
    
    final name = '${prefix ?? 'football_stats'}_${dateStr}_$timeStr';
    
    switch (format) {
      case ExportFormat.csv:
        return '$name.csv';
      case ExportFormat.pdf:
        return '$name.pdf';
      case ExportFormat.json:
        return '$name.json';
      case ExportFormat.excel:
        return '$name.xlsx';
    }
  }

  static String getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.excel:
        return 'xlsx';
    }
  }

  static String getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'Comma-separated values file, compatible with Excel and other spreadsheet applications';
      case ExportFormat.pdf:
        return 'Portable Document Format, ideal for sharing and printing';
      case ExportFormat.json:
        return 'JavaScript Object Notation, ideal for data interchange and archival';
      case ExportFormat.excel:
        return 'Microsoft Excel format with advanced formatting and charts';
    }
  }
}

// Providers
final exportProvider = StateNotifierProvider<ExportNotifier, ExportState>((ref) {
  return ExportNotifier();
});

final exportConfigProvider = StateProvider<ExportConfigModel>((ref) {
  return ExportConfigModel(
    format: ExportFormat.csv,
    dataType: ExportDataType.all,
    fileName: ExportUtils.generateFileName(ExportFormat.csv),
    title: 'Football Statistics Report',
    dateGenerated: DateTime.now(),
  );
});

// Quick Export Actions
final quickExportProvider = Provider((ref) {
  return QuickExportActions(ref);
});

class QuickExportActions {
  final Ref _ref;

  QuickExportActions(this._ref);

  Future<String?> exportAllAsCSV() async {
    final config = ExportConfigModel(
      format: ExportFormat.csv,
      dataType: ExportDataType.all,
      fileName: ExportUtils.generateFileName(ExportFormat.csv, prefix: 'all_stats'),
      title: 'Complete Football Statistics Export',
    );

    return await _performExport(config);
  }

  Future<String?> exportChartsAsPDF() async {
    final config = ExportConfigModel(
      format: ExportFormat.pdf,
      dataType: ExportDataType.charts,
      fileName: ExportUtils.generateFileName(ExportFormat.pdf, prefix: 'charts'),
      title: 'Football Statistics Charts',
    );

    return await _performExport(config);
  }

  Future<String?> exportStatisticsAsJSON() async {
    final config = ExportConfigModel(
      format: ExportFormat.json,
      dataType: ExportDataType.statistics,
      fileName: ExportUtils.generateFileName(ExportFormat.json, prefix: 'statistics'),
      title: 'Team Statistics Data',
    );

    return await _performExport(config);
  }

  Future<String?> _performExport(ExportConfigModel config) async {
    final statisticsData = _ref.read(statisticsProvider);
    final chartData = <ChartDataType, ChartDataModel>{};
    
    // Collect all chart data
    for (final type in ChartDataType.values) {
      try {
        chartData[type] = _ref.read(chartDataProvider(type));
      } catch (e) {
        // Skip charts that fail to load
      }
    }

    final exportNotifier = _ref.read(exportProvider.notifier);
    return await exportNotifier.exportData(
      config: config,
      statisticsData: statisticsData,
      chartData: chartData,
    );
  }
}