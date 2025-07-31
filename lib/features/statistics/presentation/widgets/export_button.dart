import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:share_plus/share_plus.dart'; // Not available in this project
import '../../data/models/statistics_filter_model.dart';
import '../providers/export_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/chart_data_provider.dart';

class ExportButton extends ConsumerStatefulWidget {
  final bool isCompact;
  final List<ExportFormat>? allowedFormats;
  final String? customTitle;
  final VoidCallback? onExportStarted;
  final Function(String)? onExportCompleted;
  final Function(String)? onExportFailed;

  const ExportButton({
    super.key,
    this.isCompact = false,
    this.allowedFormats,
    this.customTitle,
    this.onExportStarted,
    this.onExportCompleted,
    this.onExportFailed,
  });

  @override
  ConsumerState<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends ConsumerState<ExportButton> {
  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(exportProvider);
    
    if (widget.isCompact) {
      return _buildCompactButton(context, exportState);
    }
    
    return _buildFullButton(context, exportState);
  }

  Widget _buildCompactButton(BuildContext context, ExportState exportState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (exportState.isExporting) {
      return Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
        ),
      );
    }

    return PopupMenuButton<ExportAction>(
      icon: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.download,
          color: colorScheme.primary,
          size: 20.sp,
        ),
      ),
      onSelected: _handleQuickAction,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ExportAction.csvAll,
          child: Row(
            children: [
              Icon(Icons.table_chart, size: 16.sp),
              SizedBox(width: 8.w),
              const Text('Export CSV'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ExportAction.pdfCharts,
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 16.sp),
              SizedBox(width: 8.w),
              const Text('Export PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ExportAction.jsonData,
          child: Row(
            children: [
              Icon(Icons.code, size: 16.sp),
              SizedBox(width: 8.w),
              const Text('Export JSON'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: ExportAction.customize,
          child: Row(
            children: [
              Icon(Icons.tune, size: 16.sp),
              SizedBox(width: 8.w),
              const Text('Custom Export'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullButton(BuildContext context, ExportState exportState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.download,
                color: colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Export Data',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Export Progress
          if (exportState.isExporting)
            _buildExportProgress(context, exportState),
          
          // Export Options
          if (!exportState.isExporting)
            _buildExportOptions(context),
          
          // Last Export Info
          if (exportState.lastExportPath != null && !exportState.isExporting)
            _buildLastExportInfo(context, exportState),
          
          // Error Message
          if (exportState.error != null)
            _buildErrorMessage(context, exportState),
        ],
      ),
    );
  }

  Widget _buildExportProgress(BuildContext context, ExportState exportState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = exportState.progress;

    if (progress == null) {
      return Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Preparing export...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                progress.currentTask,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${progress.currentStep}/${progress.totalSteps}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        LinearProgressIndicator(
          value: progress.percentage,
          backgroundColor: colorScheme.outline.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
        ),
        
        SizedBox(height: 4.h),
        
        Text(
          '${(progress.percentage * 100).toStringAsFixed(0)}% complete',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    final theme = Theme.of(context);
    final allowedFormats = widget.allowedFormats ?? ExportFormat.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Export',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            if (allowedFormats.contains(ExportFormat.csv))
              _buildQuickExportChip(
                context,
                'CSV Data',
                Icons.table_chart,
                () => _handleQuickAction(ExportAction.csvAll),
              ),
            
            if (allowedFormats.contains(ExportFormat.pdf))
              _buildQuickExportChip(
                context,
                'PDF Report',
                Icons.picture_as_pdf,
                () => _handleQuickAction(ExportAction.pdfCharts),
              ),
            
            if (allowedFormats.contains(ExportFormat.json))
              _buildQuickExportChip(
                context,
                'JSON Export',
                Icons.code,
                () => _handleQuickAction(ExportAction.jsonData),
              ),
          ],
        ),
        
        SizedBox(height: 16.h),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCustomExportDialog(context),
            icon: const Icon(Icons.tune),
            label: const Text('Custom Export'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickExportChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: colorScheme.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastExportInfo(BuildContext context, ExportState exportState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colorScheme.primary,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last export completed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  exportState.lastExportPath!.split('/').last,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _shareLastExport(exportState.lastExportPath!),
            icon: Icon(
              Icons.share,
              size: 16.sp,
              color: colorScheme.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 24.w,
              minHeight: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, ExportState exportState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Failed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  exportState.error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(exportProvider.notifier).clearError(),
            icon: Icon(
              Icons.close,
              size: 16.sp,
              color: colorScheme.error,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 24.w,
              minHeight: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(ExportAction action) async {
    widget.onExportStarted?.call();
    
    final quickExport = ref.read(quickExportProvider);
    String? exportPath;

    try {
      switch (action) {
        case ExportAction.csvAll:
          exportPath = await quickExport.exportAllAsCSV();
          break;
        case ExportAction.pdfCharts:
          exportPath = await quickExport.exportChartsAsPDF();
          break;
        case ExportAction.jsonData:
          exportPath = await quickExport.exportStatisticsAsJSON();
          break;
        case ExportAction.customize:
          _showCustomExportDialog(context);
          return;
      }

      if (exportPath != null) {
        widget.onExportCompleted?.call(exportPath);
        _showExportSuccessDialog(context, exportPath);
      } else {
        widget.onExportFailed?.call('Export failed');
      }
    } catch (e) {
      widget.onExportFailed?.call(e.toString());
    }
  }

  void _showCustomExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomExportDialog(),
    );
  }

  void _showExportSuccessDialog(BuildContext context, String filePath) {
    final fileName = filePath.split('/').last;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your data has been exported successfully:'),
            SizedBox(height: 8.h),
            Text(
              fileName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _shareLastExport(filePath);
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  void _shareLastExport(String filePath) async {
    try {
      // Sharing functionality would require share_plus package
      // For now, just show the file path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved: ${filePath.split('/').last}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to access file: $e')),
        );
      }
    }
  }
}

// Custom Export Dialog
class CustomExportDialog extends ConsumerStatefulWidget {
  const CustomExportDialog({super.key});

  @override
  ConsumerState<CustomExportDialog> createState() => _CustomExportDialogState();
}

class _CustomExportDialogState extends ConsumerState<CustomExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportDataType _selectedDataType = ExportDataType.all;
  bool _includeCharts = true;
  bool _includeStatistics = true;
  bool _includeFilters = true;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Football Statistics Report';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Custom Export'),
      content: SizedBox(
        width: 400.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Format Selection
              Text(
                'Export Format',
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8.h),
              
              ...ExportFormat.values.map((format) => RadioListTile<ExportFormat>(
                title: Text(format.name.toUpperCase()),
                subtitle: Text(ExportUtils.getFormatDescription(format)),
                value: format,
                groupValue: _selectedFormat,
                onChanged: (value) => setState(() => _selectedFormat = value!),
                dense: true,
              )),
              
              SizedBox(height: 16.h),
              
              // Data Type Selection
              Text(
                'Data to Export',
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8.h),
              
              ...ExportDataType.values.map((dataType) => RadioListTile<ExportDataType>(
                title: Text(dataType.name.replaceAll('_', ' ').toUpperCase()),
                value: dataType,
                groupValue: _selectedDataType,
                onChanged: (value) => setState(() => _selectedDataType = value!),
                dense: true,
              )),
              
              SizedBox(height: 16.h),
              
              // Include Options
              Text(
                'Include Options',
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8.h),
              
              CheckboxListTile(
                title: const Text('Charts'),
                value: _includeCharts,
                onChanged: (value) => setState(() => _includeCharts = value!),
                dense: true,
              ),
              
              CheckboxListTile(
                title: const Text('Statistics'),
                value: _includeStatistics,
                onChanged: (value) => setState(() => _includeStatistics = value!),
                dense: true,
              ),
              
              CheckboxListTile(
                title: const Text('Filter Settings'),
                value: _includeFilters,
                onChanged: (value) => setState(() => _includeFilters = value!),
                dense: true,
              ),
              
              SizedBox(height: 16.h),
              
              // Title and Description
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Report Title',
                  border: OutlineInputBorder(),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _performCustomExport,
          child: const Text('Export'),
        ),
      ],
    );
  }

  void _performCustomExport() async {
    final config = ExportConfigModel(
      format: _selectedFormat,
      dataType: _selectedDataType,
      includeCharts: _includeCharts,
      includeStatistics: _includeStatistics,
      includeFilters: _includeFilters,
      fileName: ExportUtils.generateFileName(_selectedFormat),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
        ? null 
        : _descriptionController.text.trim(),
      dateGenerated: DateTime.now(),
    );

    Navigator.of(context).pop();

    final statisticsData = ref.read(statisticsProvider);
    final chartData = <ChartDataType, ChartDataModel>{};
    
    // Collect chart data
    for (final type in ChartDataType.values) {
      try {
        chartData[type] = ref.read(chartDataProvider(type));
      } catch (e) {
        // Skip failed charts
      }
    }

    final exportNotifier = ref.read(exportProvider.notifier);
    final exportPath = await exportNotifier.exportData(
      config: config,
      statisticsData: statisticsData,
      chartData: chartData,
    );

    if (exportPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export completed: ${exportPath.split('/').last}'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Could open file location or show file details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('File location: $exportPath')),
              );
            },
          ),
        ),
      );
    }
  }
}

enum ExportAction {
  csvAll,
  pdfCharts,
  jsonData,
  customize,
}