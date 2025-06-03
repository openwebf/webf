/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webf/launcher.dart';

/// A floating inspector panel for WebF that provides debugging tools and insights.
///
/// This panel currently includes:
/// - Controller management and monitoring
///
/// By default, this panel is only visible in debug mode. You can override this
/// behavior by setting the [visible] parameter.
class WebFInspectorFloatingPanel extends StatefulWidget {
  /// Whether the inspector panel should be visible.
  /// If null, defaults to kDebugMode (only visible in debug builds).
  final bool? visible;

  const WebFInspectorFloatingPanel({
    Key? key,
    this.visible,
  }) : super(key: key);

  @override
  State<WebFInspectorFloatingPanel> createState() => _WebFInspectorFloatingPanelState();
}

class _WebFInspectorFloatingPanelState extends State<WebFInspectorFloatingPanel> {
  Offset _position = Offset(20, 100); // Initial position
  Timer? _refreshTimer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Position the button on the right side by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(size.width - 80, size.height * 0.7);
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _showInspectorPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WebFInspectorBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check visibility - only show in debug mode by default
    final bool isVisible = widget.visible ?? kDebugMode;
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;

    // Ensure the button stays within screen bounds
    double x = _position.dx.clamp(0, size.width - 60);
    double y = _position.dy.clamp(50, size.height - 100);

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () {
          if (!_isDragging) {
            _showInspectorPanel();
          }
          _isDragging = false;
        },
        onPanStart: (_) {
          _isDragging = false;
        },
        onPanUpdate: (details) {
          _isDragging = true;
          setState(() {
            _position = Offset(
              (_position.dx + details.delta.dx).clamp(0, size.width - 60),
              (_position.dy + details.delta.dy).clamp(50, size.height - 100),
            );
          });
        },
        onPanEnd: (_) {
          // Snap to the nearest edge
          final middle = size.width / 2;
          setState(() {
            if (_position.dx < middle) {
              _position = Offset(20, _position.dy);
            } else {
              _position = Offset(size.width - 80, _position.dy);
            }
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.bug_report,
                  color: Colors.white,
                  size: 28,
                ),
                // Badge showing controller count
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${WebFControllerManager.instance.controllerCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebFInspectorBottomSheet extends StatefulWidget {
  @override
  State<_WebFInspectorBottomSheet> createState() => _WebFInspectorBottomSheetState();
}

class _WebFInspectorBottomSheetState extends State<_WebFInspectorBottomSheet> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh the panel every second to show real-time updates
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'WebF DevTools',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Controllers content only
          Expanded(
            child: _buildControllersTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildControllersTab() {
    final manager = WebFControllerManager.instance;
    final config = manager.config;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Controllers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildQuickStats(),
          SizedBox(height: 16),
          _buildConfigInfo(config),
          SizedBox(height: 16),
          _buildActionButtons(manager),
          SizedBox(height: 16),
          Expanded(
            child: _buildControllersList(manager),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickStats() {
    final manager = WebFControllerManager.instance;
    final attachedCount = manager.attachedControllersCount;
    final detachedCount = manager.detachedControllersCount;
    final totalCount = manager.controllerCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatChip('Total', totalCount, Colors.blue),
        SizedBox(width: 8),
        _buildStatChip('Attached', attachedCount, Colors.green),
        SizedBox(width: 8),
        _buildStatChip('Detached', detachedCount, Colors.orange),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConfigInfo(WebFControllerManagerConfig config) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildConfigItem('Max Alive', config.maxAliveInstances),
          _buildConfigItem('Max Attached', config.maxAttachedInstances),
          _buildConfigItem(
            'Auto Dispose',
            config.autoDisposeWhenLimitReached ? 'ON' : 'OFF',
            isText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String label, dynamic value, {bool isText = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: isText && value == 'ON' ? Colors.green : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(WebFControllerManager manager) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: manager.controllerCount > 0
                ? () async {
                    // Show confirmation dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Disposal'),
                        content: Text(
                            'Are you sure you want to dispose all ${manager.controllerCount} controllers?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Dispose All',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await manager.disposeAll();
                      // Close the bottom sheet
                      Navigator.of(context).pop();
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All controllers have been disposed'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                : null,
            icon: Icon(Icons.delete_sweep, size: 16),
            label: Text('Dispose All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControllersList(WebFControllerManager manager) {
    final controllerNames = manager.controllerNames;

    if (controllerNames.isEmpty) {
      return Center(
        child: Text(
          'No controllers registered',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: controllerNames.length,
      itemBuilder: (context, index) {
        final name = controllerNames[index];
        final state = manager.getControllerState(name);
        final controller = manager.getControllerSync(name);

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getStateColor(state).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStateColor(state),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (controller != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'URL: ${controller.url}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStateColor(state).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStateText(state),
                  style: TextStyle(
                    color: _getStateColor(state),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (controller != null && state == ControllerState.detached) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh, size: 18),
                  color: Colors.white70,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () async {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Reloading...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    try {
                      // Reload the controller
                      await controller.reload();

                      // Close loading dialog
                      Navigator.of(context).pop();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Controller reloaded successfully'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Close loading dialog
                      Navigator.of(context).pop();

                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to reload: ${e.toString()}'),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  tooltip: 'Reload Controller',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getStateColor(ControllerState? state) {
    switch (state) {
      case ControllerState.attached:
        return Colors.green;
      case ControllerState.detached:
        return Colors.orange;
      case ControllerState.disposed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStateText(ControllerState? state) {
    switch (state) {
      case ControllerState.attached:
        return 'ATTACHED';
      case ControllerState.detached:
        return 'DETACHED';
      case ControllerState.disposed:
        return 'DISPOSED';
      default:
        return 'UNKNOWN';
    }
  }
}
