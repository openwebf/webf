/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/devtools/network_store.dart';
import 'package:webf/src/foundation/http_cache.dart';

/// A floating inspector panel for WebF that provides debugging tools and insights.
///
/// This panel currently includes:
/// - Controller management and monitoring
/// - Hybrid router stack visualization
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

class _WebFInspectorBottomSheetState extends State<_WebFInspectorBottomSheet> with SingleTickerProviderStateMixin {
  Timer? _refreshTimer;
  late TabController _tabController;

  // Static variable to remember the last selected tab
  static int _lastSelectedTabIndex = 0;

  // Track the original cache mode to restore it when unchecked
  final HttpCacheMode _originalCacheMode = HttpCacheController.mode;
  // Track whether cache is disabled
  bool _isCacheDisabled = HttpCacheController.mode == HttpCacheMode.NO_CACHE;
  
  // Track which response bodies are expanded
  final Set<String> _expandedResponseBodies = {};
  final Set<String> _expandedRequestBodies = {};
  
  // Track which headers sections are expanded
  final Set<String> _expandedHeaders = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _lastSelectedTabIndex,
    );

    // Listen to tab changes to save the selected index
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _lastSelectedTabIndex = _tabController.index;
      }
    });

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
    _tabController.dispose();
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
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'Controllers'),
                Tab(text: 'Routes'),
                Tab(text: 'Network'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildControllersTab(),
                _buildRoutesTab(),
                _buildNetworkTab(),
              ],
            ),
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

  Widget _buildStatChip(String label, dynamic value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
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

  Widget _buildRoutesTab() {
    final manager = WebFControllerManager.instance;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildRoutesList(),
          ),
        ],
      ),
    );
  }


  Widget _buildRoutesList() {
    final manager = WebFControllerManager.instance;
    final controllerNames = manager.controllerNames;

    if (controllerNames.isEmpty) {
      return Center(
        child: Text(
          'No controllers with routes',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: controllerNames.length,
      itemBuilder: (context, index) {
        final name = controllerNames[index];
        final controller = manager.getControllerSync(name);
        final state = manager.getControllerState(name);

        if (controller == null || controller.buildContextStack.isEmpty) {
          return SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getStateColor(state).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Controller: $name',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Stack Size: ${controller.buildContextStack.length}',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
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
                  ],
                ),
              ),
              _buildRouteStack(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteStack(WebFController controller) {
    final stack = controller.buildContextStack;

    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: List.generate(stack.length, (index) {
          final routeContext = stack[index];
          final isCurrentRoute = index == stack.length - 1;

          return Container(
            margin: EdgeInsets.only(bottom: index < stack.length - 1 ? 8 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stack indicator
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrentRoute ? Colors.green : Colors.blue,
                        border: Border.all(
                          color: isCurrentRoute ? Colors.green.shade300 : Colors.blue.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (index < stack.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: Colors.white24,
                      ),
                  ],
                ),
                SizedBox(width: 12),
                // Route info
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentRoute ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isCurrentRoute ? Colors.green.withOpacity(0.3) : Colors.white10,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              size: 16,
                              color: isCurrentRoute ? Colors.green : Colors.white54,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                routeContext.path,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrentRoute)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Widget: ${routeContext.context.widget.runtimeType}',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        if (routeContext.state != null) ...[
                          SizedBox(height: 4),
                          Text(
                            'State: ${routeContext.state}',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (index == 0) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.foundation,
                                size: 12,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'ROOT',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNetworkTab() {
    // Get the current active controller
    final manager = WebFControllerManager.instance;

    // Try to get the first attached controller for network data
    WebFController? activeController;
    for (final name in manager.controllerNames) {
      final controller = manager.getControllerSync(name);
      final state = manager.getControllerState(name);
      if (controller != null && state == ControllerState.attached) {
        activeController = controller;
        break;
      }
    }

    if (activeController == null) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No active controller available',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    // Get network requests for the active controller
    final contextId = activeController.view.contextId.toInt();
    final requests = NetworkStore().getRequestsForContext(contextId);

    return Column(
      children: [
        // Main content area
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clear button and cache toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: requests.isNotEmpty
                              ? () {
                                  setState(() {
                                    NetworkStore().clearContext(contextId);
                                  });
                                }
                              : null,
                          icon: Icon(Icons.clear_all, size: 16),
                          tooltip: 'Clear all requests',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.orange.withOpacity(0.2),
                            foregroundColor: Colors.orange,
                            padding: EdgeInsets.all(6),
                            minimumSize: Size(32, 32),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: 32,
                            maxHeight: 32,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Disable cache',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 8),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isCacheDisabled,
                            onChanged: (value) {
                              setState(() {
                                _isCacheDisabled = value;
                                if (value) {
                                  HttpCacheController.mode = HttpCacheMode.NO_CACHE;
                                } else {
                                  HttpCacheController.mode = _originalCacheMode;
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Network requests list
                Expanded(
                  child: requests.isEmpty
                      ? Center(
                          child: Text(
                            'No network requests captured',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index]; // Show chronological order
                            return _buildNetworkRequestItem(request);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        // Fixed bottom stats bar
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(
              top: BorderSide(color: Colors.white10, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildNetworkStats(requests),
        ),
      ],
    );
  }

  Widget _buildNetworkStats(List<NetworkRequest> requests) {
    int successCount = 0;
    int errorCount = 0;
    int pendingCount = 0;
    int totalSize = 0;

    for (final request in requests) {
      if (!request.isComplete) {
        pendingCount++;
      } else if (request.statusCode != null) {
        if (request.statusCode! >= 200 && request.statusCode! < 300) {
          successCount++;
        } else if (request.statusCode! >= 400) {
          errorCount++;
        }
        totalSize += request.responseSize;
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildStatChip('Total', requests.length, Colors.blue),
        _buildStatChip('Success', successCount, Colors.green),
        _buildStatChip('Error', errorCount, Colors.red),
        _buildStatChip('Pending', pendingCount, Colors.orange),
        _buildStatChip('Size', _formatBytes(totalSize), Colors.purple),
      ],
    );
  }

  Widget _buildNetworkRequestItem(NetworkRequest request) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: request.statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: EdgeInsets.all(12),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: request.statusColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _getRequestIcon(request.method),
              color: request.statusColor,
              size: 18,
            ),
          ),
        ),
        title: Text(
          _formatUrl(request.url),
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
          ),
          softWrap: true,
        ),
        subtitle: Row(
          children: [
            Text(
              request.method,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            if (request.statusCode != null) ...[
              Text(
                '${request.statusCode}',
                style: TextStyle(
                  color: request.statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
            ],
            if (request.duration != null) ...[
              Icon(Icons.timer, size: 12, color: Colors.white54),
              SizedBox(width: 4),
              Text(
                _formatDuration(request.duration!),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
              SizedBox(width: 8),
            ],
            if (request.responseSize > 0) ...[
              Icon(Icons.download, size: 12, color: Colors.white54),
              SizedBox(width: 4),
              Text(
                _formatBytes(request.responseSize),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        trailing: request.isComplete
            ? Icon(
                Icons.check_circle,
                color: request.statusColor,
                size: 16,
              )
            : SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
        children: [
          _buildRequestDetails(request),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(NetworkRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full URL
        _buildDetailSection(
          'URL',
          request.url,
          Icons.link,
          isUrl: true,
        ),
        SizedBox(height: 12),
        // Request headers
        if (request.requestHeaders.isNotEmpty) ...[
          _buildHeadersSection('Request Headers', request.requestHeaders, '${request.requestId}_request'),
          SizedBox(height: 12),
        ],
        // Request body
        if (request.requestData.isNotEmpty) ...[
          _buildExpandableRequestBody(request),
          SizedBox(height: 12),
        ],
        // Response headers
        if (request.responseHeaders != null && request.responseHeaders!.isNotEmpty) ...[
          _buildHeadersSection('Response Headers', request.responseHeaders!, '${request.requestId}_response'),
          SizedBox(height: 12),
        ],
        // Response body preview
        if (request.responseBody != null && request.responseBody!.isNotEmpty) ...[
          _buildExpandableResponseBody(request),
        ],
      ],
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, {bool isUrl = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white54),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isUrl) ...[
                Spacer(),
                IconButton(
                  icon: Icon(Icons.copy, size: 16),
                  color: Colors.white54,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('URL copied to clipboard'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green.withOpacity(0.8),
                      ),
                    );
                  },
                  tooltip: 'Copy URL',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          isUrl
              ? GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('URL copied to clipboard'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green.withOpacity(0.8),
                      ),
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              : Text(
                  content,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }

  Widget _buildHeadersSection(String title, Map<String, List<String>> headers, String sectionId) {
    final isExpanded = _expandedHeaders.contains(sectionId);
    final showAllHeaders = isExpanded || headers.length <= 3; // Show first 3 headers when collapsed
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list, size: 16, color: Colors.white54),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Copy all headers button
              IconButton(
                icon: Icon(Icons.copy_all, size: 16),
                color: Colors.white54,
                onPressed: () async {
                  final allHeaders = headers.entries
                      .map((e) => '${e.key}: ${e.value.join(', ')}')
                      .join('\n');
                  await Clipboard.setData(ClipboardData(text: allHeaders));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All headers copied to clipboard'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green.withOpacity(0.8),
                    ),
                  );
                },
                tooltip: 'Copy all headers',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              // Expand/collapse button (only show if more than 3 headers)
              if (headers.length > 3) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  color: Colors.white54,
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedHeaders.remove(sectionId);
                      } else {
                        _expandedHeaders.add(sectionId);
                      }
                    });
                  },
                  tooltip: isExpanded ? 'Collapse' : 'Expand',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          ...(showAllHeaders ? headers.entries : headers.entries.take(3)).map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: () async {
                    final headerText = '${entry.key}: ${entry.value.join(', ')}';
                    await Clipboard.setData(ClipboardData(text: headerText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Header copied to clipboard'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green.withOpacity(0.8),
                      ),
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.join(', '),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontFamily: 'monospace',
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dotted,
                                decorationColor: Colors.white30,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.copy,
                            size: 12,
                            color: Colors.white30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          // Show count of hidden headers when collapsed
          if (!isExpanded && headers.length > 3) ...[
            SizedBox(height: 4),
            Text(
              '... and ${headers.length - 3} more',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableResponseBody(NetworkRequest request) {
    final isExpanded = _expandedResponseBodies.contains(request.requestId);
    
    // Try to detect if it's an image by checking the actual content
    final isImage = _isImageData(request.responseBody!);
    
    String? responseString;
    dynamic jsonData;
    bool isJson = false;
    
    if (!isImage) {
      try {
        responseString = utf8.decode(request.responseBody!, allowMalformed: true);
        
        // Try to parse JSON
        if (request.mimeType?.contains('json') ?? false || responseString.trimLeft().startsWith('{') || responseString.trimLeft().startsWith('[')) {
          try {
            jsonData = jsonDecode(responseString);
            isJson = true;
          } catch (_) {
            // Not valid JSON, show as is
          }
        }
      } catch (_) {
        // If decoding fails, show as binary data
        responseString = 'Binary data (cannot display)';
      }
    }
    
    final isLongResponse = !isImage && !isJson && responseString != null && responseString.length > 500;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.download, size: 16, color: Colors.white54),
              SizedBox(width: 8),
              Text(
                'Response Body (${_formatBytes(request.responseBody!.length)})',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              // Copy button (only for non-image content)
              if (!isImage) ...[
                IconButton(
                  icon: Icon(Icons.copy, size: 16),
                  color: Colors.white54,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: responseString!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Response body copied to clipboard'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green.withOpacity(0.8),
                      ),
                    );
                  },
                  tooltip: 'Copy response body',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
              // Expand/collapse button (show for long responses, images, or JSON)
              if (isLongResponse || isImage || isJson) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  color: Colors.white54,
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedResponseBodies.remove(request.requestId);
                      } else {
                        _expandedResponseBodies.add(request.requestId);
                      }
                    });
                  },
                  tooltip: isExpanded ? 'Collapse' : 'Expand',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          // Response content
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: isImage
                ? _buildImagePreview(request, isExpanded)
                : isJson
                    ? _buildJsonViewer(jsonData, isExpanded)
                    : SelectableText(
                        responseString ?? '',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: isExpanded ? null : 10,
                      ),
          ),
          // Show preview info if collapsed and response is long
          if (!isExpanded && isLongResponse) ...[
            SizedBox(height: 4),
            Text(
              'Click expand to see full response',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableRequestBody(NetworkRequest request) {
    final isExpanded = _expandedRequestBodies.contains(request.requestId);
    bool isJson = false;
    bool isFormData = false;
    String? requestString;
    dynamic jsonData;
    Map<String, String>? formDataFields;
    
    // Check content type from request headers
    final contentType = request.requestHeaders['content-type']?.first ?? '';
    
    try {
      requestString = utf8.decode(request.requestData, allowMalformed: true);
      
      // Try to parse JSON
      if (contentType.contains('json') || requestString.trimLeft().startsWith('{') || requestString.trimLeft().startsWith('[')) {
        try {
          jsonData = jsonDecode(requestString);
          isJson = true;
        } catch (_) {
          // Not valid JSON
        }
      }
      
      // Check if it's form data
      if (contentType.contains('application/x-www-form-urlencoded')) {
        isFormData = true;
        formDataFields = Uri.splitQueryString(requestString);
      } else if (contentType.contains('multipart/form-data')) {
        isFormData = true;
        // For multipart, just show the raw data for now
        // TODO: Parse multipart form data properly
      }
    } catch (_) {
      // If decoding fails, show as binary data
      requestString = 'Binary data (cannot display)';
    }
    
    final isLongRequest = !isJson && !isFormData && requestString != null && requestString.length > 500;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload, size: 16, color: Colors.white54),
              SizedBox(width: 8),
              Text(
                'Request Body (${_formatBytes(request.requestData.length)})',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (contentType.isNotEmpty) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    contentType.split(';').first,
                    style: TextStyle(
                      color: Colors.blue.shade300,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              Spacer(),
              // Copy button
              IconButton(
                icon: Icon(Icons.copy, size: 16),
                color: Colors.white54,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: requestString ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request body copied to clipboard'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green.withOpacity(0.8),
                    ),
                  );
                },
                tooltip: 'Copy request body',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              // Expand/collapse button
              if (isLongRequest || isJson || isFormData) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  color: Colors.white54,
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedRequestBodies.remove(request.requestId);
                      } else {
                        _expandedRequestBodies.add(request.requestId);
                      }
                    });
                  },
                  tooltip: isExpanded ? 'Collapse' : 'Expand',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          // Request content
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: isJson
                ? _buildJsonViewer(jsonData, isExpanded)
                : isFormData && formDataFields != null
                    ? _buildFormDataViewer(formDataFields, isExpanded)
                    : SelectableText(
                        requestString ?? '',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: isExpanded ? null : 10,
                      ),
          ),
          // Show preview info if collapsed and request is long
          if (!isExpanded && isLongRequest) ...[
            SizedBox(height: 4),
            Text(
              'Click expand to see full request',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormDataViewer(Map<String, String> formData, bool isExpanded) {
    final entries = formData.entries.toList();
    final displayCount = isExpanded ? entries.length : 5.clamp(0, entries.length);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < displayCount; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SelectableText(
                  '${entries[i].key}:',
                  style: TextStyle(
                    color: Colors.lightBlue.shade300,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: SelectableText(
                  entries[i].value,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          if (i < displayCount - 1) SizedBox(height: 4),
        ],
        if (!isExpanded && entries.length > 5) ...[
          SizedBox(height: 4),
          Text(
            '... and ${entries.length - 5} more fields',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getRequestIcon(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Icons.download_outlined;
      case 'POST':
        return Icons.upload_outlined;
      case 'PUT':
        return Icons.edit_outlined;
      case 'DELETE':
        return Icons.delete_outline;
      case 'PATCH':
        return Icons.build_outlined;
      default:
        return Icons.http;
    }
  }

  String _formatUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.host}${uri.path}${uri.query.isNotEmpty ? '?...' : ''}';
    } catch (_) {
      return url;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  bool _isImageData(Uint8List data) {
    if (data.isEmpty) return false;
    
    // Check for common image file signatures (magic numbers)
    // PNG signature: 89 50 4E 47 0D 0A 1A 0A
    if (data.length >= 8 && 
        data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47 &&
        data[4] == 0x0D && data[5] == 0x0A && data[6] == 0x1A && data[7] == 0x0A) {
      return true;
    }
    
    // JPEG signature: FF D8 FF
    if (data.length >= 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
      return true;
    }
    
    // GIF signature: 47 49 46 38 (GIF87a or GIF89a)
    if (data.length >= 6 && 
        data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46 && data[3] == 0x38) {
      return true;
    }
    
    // WebP signature: 52 49 46 46 ?? ?? ?? ?? 57 45 42 50 (RIFF....WEBP)
    if (data.length >= 12 && 
        data[0] == 0x52 && data[1] == 0x49 && data[2] == 0x46 && data[3] == 0x46 &&
        data[8] == 0x57 && data[9] == 0x45 && data[10] == 0x42 && data[11] == 0x50) {
      return true;
    }
    
    // BMP signature: 42 4D (BM)
    if (data.length >= 2 && data[0] == 0x42 && data[1] == 0x4D) {
      return true;
    }
    
    // ICO signature: 00 00 01 00
    if (data.length >= 4 && 
        data[0] == 0x00 && data[1] == 0x00 && data[2] == 0x01 && data[3] == 0x00) {
      return true;
    }
    
    // SVG detection - check if it starts with XML or SVG tags
    try {
      final str = utf8.decode(data.take(1000).toList(), allowMalformed: true).toLowerCase();
      if (str.contains('<svg') || (str.contains('<?xml') && str.contains('svg'))) {
        return true;
      }
    } catch (_) {
      // Not text, continue checking
    }
    
    return false;
  }
  
  bool _isSvgData(Uint8List data) {
    if (data.isEmpty) return false;
    
    try {
      final str = utf8.decode(data, allowMalformed: true).toLowerCase().trim();
      // Check if it starts with common SVG patterns
      if (str.startsWith('<svg') || 
          str.startsWith('<?xml') && str.contains('<svg') ||
          str.contains('xmlns="http://www.w3.org/2000/svg"')) {
        return true;
      }
    } catch (_) {
      // Not text, definitely not SVG
    }
    
    return false;
  }
  
  Widget _buildImagePreview(NetworkRequest request, bool isExpanded) {
    final isSvg = _isSvgData(request.responseBody!);
    
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: isExpanded ? double.infinity : 200,
            maxWidth: double.infinity,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: isSvg
                ? _buildSvgPreview(request.responseBody!, isExpanded)
                : Image.memory(
                    request.responseBody!,
                    fit: isExpanded ? BoxFit.contain : BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey.withOpacity(0.3),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.red.withOpacity(0.5),
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (!isExpanded) ...[
          SizedBox(height: 8),
          Text(
            'Click expand to see full image',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildSvgPreview(Uint8List svgData, bool isExpanded) {
    try {
      final svgString = utf8.decode(svgData);
      return SvgPicture.string(
        svgString,
        fit: isExpanded ? BoxFit.contain : BoxFit.cover,
        placeholderBuilder: (context) => Container(
          color: Colors.grey.withOpacity(0.3),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: 100,
        color: Colors.grey.withOpacity(0.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: Colors.red.withOpacity(0.5),
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                'Failed to load SVG',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Error: ${e.toString()}',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildJsonViewer(dynamic jsonData, bool isExpanded) {
    if (!isExpanded) {
      // Show a preview when collapsed
      String preview;
      if (jsonData is Map) {
        preview = '{...} ${jsonData.length} properties';
      } else if (jsonData is List) {
        preview = '[...] ${jsonData.length} items';
      } else {
        preview = jsonData.toString();
      }
      
      return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preview,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Click expand to explore JSON structure',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    
    // Show interactive JSON tree when expanded
    return _JsonTreeView(data: jsonData);
  }
}

// Interactive JSON Tree View Widget
class _JsonTreeView extends StatefulWidget {
  final dynamic data;
  final int depth;
  
  const _JsonTreeView({
    Key? key,
    required this.data,
    this.depth = 0,
  }) : super(key: key);
  
  @override
  _JsonTreeViewState createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<_JsonTreeView> {
  final Set<String> _expandedKeys = {};
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildJsonTree(widget.data, '', widget.depth),
    );
  }
  
  Widget _buildJsonTree(dynamic data, String path, int depth) {
    final indent = depth * 16.0;
    
    if (data is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (depth > 0) 
            Padding(
              padding: EdgeInsets.only(left: indent - 16),
              child: Text('{', style: _getTextStyle(depth)),
            ),
          ...data.entries.map((entry) {
            final key = entry.key.toString();
            final currentPath = path.isEmpty ? key : '$path.$key';
            final isExpanded = _expandedKeys.contains(currentPath);
            final value = entry.value;
            final isExpandable = value is Map || value is List;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: indent),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isExpandable) ...[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedKeys.remove(currentPath);
                                } else {
                                  _expandedKeys.add(currentPath);
                                }
                              });
                            },
                            child: Icon(
                              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                              size: 16,
                              color: Colors.white54,
                            ),
                          ),
                        ] else ...[
                          SizedBox(width: 16),
                        ],
                        SelectableText(
                          '"$key": ',
                          style: TextStyle(
                            color: Colors.blue.shade300,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (!isExpandable) ...[
                          Expanded(
                            child: SelectableText(
                              _formatJsonValue(value),
                              style: _getValueStyle(value),
                            ),
                          ),
                        ] else if (!isExpanded) ...[
                          Text(
                            value is Map ? '{...}' : '[...]',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isExpandable && isExpanded) ...[
                  _buildJsonTree(value, currentPath, depth + 1),
                ],
              ],
            );
          }).toList(),
          if (depth > 0) 
            Padding(
              padding: EdgeInsets.only(left: indent - 16),
              child: Text('}', style: _getTextStyle(depth)),
            ),
        ],
      );
    } else if (data is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (depth > 0) 
            Padding(
              padding: EdgeInsets.only(left: indent - 16),
              child: Text('[', style: _getTextStyle(depth)),
            ),
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final currentPath = '$path[$index]';
            final isExpanded = _expandedKeys.contains(currentPath);
            final value = entry.value;
            final isExpandable = value is Map || value is List;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: indent),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isExpandable) ...[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedKeys.remove(currentPath);
                                } else {
                                  _expandedKeys.add(currentPath);
                                }
                              });
                            },
                            child: Icon(
                              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                              size: 16,
                              color: Colors.white54,
                            ),
                          ),
                        ] else ...[
                          SizedBox(width: 16),
                        ],
                        Text(
                          '[$index]: ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (!isExpandable) ...[
                          Expanded(
                            child: SelectableText(
                              _formatJsonValue(value),
                              style: _getValueStyle(value),
                            ),
                          ),
                        ] else if (!isExpanded) ...[
                          Text(
                            value is Map ? '{...}' : '[...]',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isExpandable && isExpanded) ...[
                  _buildJsonTree(value, currentPath, depth + 1),
                ],
              ],
            );
          }).toList(),
          if (depth > 0) 
            Padding(
              padding: EdgeInsets.only(left: indent - 16),
              child: Text(']', style: _getTextStyle(depth)),
            ),
        ],
      );
    } else {
      return SelectableText(
        _formatJsonValue(data),
        style: _getValueStyle(data),
      );
    }
  }
  
  TextStyle _getTextStyle(int depth) {
    return TextStyle(
      color: Colors.white54,
      fontSize: 11,
      fontFamily: 'monospace',
    );
  }
  
  TextStyle _getValueStyle(dynamic value) {
    Color color;
    if (value == null) {
      color = Colors.grey;
    } else if (value is String) {
      color = Colors.green.shade300;
    } else if (value is num) {
      color = Colors.orange.shade300;
    } else if (value is bool) {
      color = Colors.purple.shade300;
    } else {
      color = Colors.white70;
    }
    
    return TextStyle(
      color: color,
      fontSize: 11,
      fontFamily: 'monospace',
    );
  }
  
  String _formatJsonValue(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      return '"$value"';
    } else {
      return value.toString();
    }
  }
}
