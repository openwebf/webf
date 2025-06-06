/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
                            final request = requests[requests.length - 1 - index]; // Show newest first
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
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        ),
        SizedBox(height: 12),
        // Request headers
        if (request.requestHeaders.isNotEmpty) ...[
          _buildHeadersSection('Request Headers', request.requestHeaders),
          SizedBox(height: 12),
        ],
        // Request body
        if (request.requestData.isNotEmpty) ...[
          _buildDetailSection(
            'Request Body',
            String.fromCharCodes(request.requestData),
            Icons.upload,
          ),
          SizedBox(height: 12),
        ],
        // Response headers
        if (request.responseHeaders != null && request.responseHeaders!.isNotEmpty) ...[
          _buildHeadersSection('Response Headers', request.responseHeaders!),
          SizedBox(height: 12),
        ],
        // Response body preview
        if (request.responseBody != null && request.responseBody!.isNotEmpty) ...[
          _buildDetailSection(
            'Response Body (${_formatBytes(request.responseBody!.length)})',
            _getResponsePreview(request),
            Icons.download,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
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
            ],
          ),
          SizedBox(height: 8),
          Text(
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

  Widget _buildHeadersSection(String title, Map<String, List<String>> headers) {
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
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...headers.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 4),
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
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
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

  String _getResponsePreview(NetworkRequest request) {
    if (request.responseBody == null) return 'No response body';

    try {
      final decoded = utf8.decode(request.responseBody!, allowMalformed: true);
      // Try to pretty print JSON
      if (request.mimeType?.contains('json') ?? false) {
        try {
          final json = jsonDecode(decoded);
          return const JsonEncoder.withIndent('  ').convert(json);
        } catch (_) {
          // Not valid JSON, show as is
        }
      }
      return decoded;
    } catch (_) {
      return 'Binary data (${_formatBytes(request.responseBody!.length)})';
    }
  }
}
