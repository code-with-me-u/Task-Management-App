import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/status_summary_card.dart';
import '../../widgets/task_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPriority = 'all'; // 'all', 'high', 'medium', 'low'
  String _selectedSort = 'newest'; // 'newest', 'oldest', 'due_earliest', 'due_latest', 'priority_high_low', 'priority_low_high'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedPriority = 'all';
      _selectedSort = 'newest';
      _tabController.animateTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    // Session Expiration Handling
    if (taskProvider.isSessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        taskProvider.clearSessionExpiredFlag();
        final nav = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        await authProvider.logout();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: AppConstants.error,
          ),
        );
        nav.pushNamedAndRemoveUntil('/login', (route) => false);
      });
    }

    final userName = authProvider.user?.name ?? 'User';
    final tasksList = taskProvider.tasks;

    return Scaffold(
      backgroundColor: AppConstants.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // App Bar Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $userName',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Track & Manage Your Tasks',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppConstants.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_outlined, color: AppConstants.textSecondary),
                            tooltip: 'Log out',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Log Out'),
                                  content: const Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel', style: TextStyle(color: AppConstants.textSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await authProvider.logout();
                                        if (context.mounted) {
                                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                        }
                                      },
                                      child: const Text('Log Out', style: TextStyle(color: AppConstants.error)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Statistics Grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - (3 * AppConstants.paddingMedium)) / 4;
                          final isSmall = constraints.maxWidth < 600;

                          if (isSmall) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatusSummaryCard(
                                        title: 'Total',
                                        count: taskProvider.totalTasksCount.toString(),
                                        icon: Icons.list_alt_rounded,
                                        color: AppConstants.accent,
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.paddingMedium),
                                    Expanded(
                                      child: StatusSummaryCard(
                                        title: 'Pending',
                                        count: taskProvider.pendingTasksCount.toString(),
                                        icon: Icons.pending_actions_rounded,
                                        color: AppConstants.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatusSummaryCard(
                                        title: 'In Progress',
                                        count: taskProvider.inProgressTasksCount.toString(),
                                        icon: Icons.sync_rounded,
                                        color: AppConstants.info,
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.paddingMedium),
                                    Expanded(
                                      child: StatusSummaryCard(
                                        title: 'Completed',
                                        count: taskProvider.completedTasksCount.toString(),
                                        icon: Icons.check_circle_outline_rounded,
                                        color: AppConstants.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: StatusSummaryCard(
                                  title: 'Total',
                                  count: taskProvider.totalTasksCount.toString(),
                                  icon: Icons.list_alt_rounded,
                                  color: AppConstants.accent,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              SizedBox(
                                width: cardWidth,
                                child: StatusSummaryCard(
                                  title: 'Pending',
                                  count: taskProvider.pendingTasksCount.toString(),
                                  icon: Icons.pending_actions_rounded,
                                  color: AppConstants.warning,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              SizedBox(
                                width: cardWidth,
                                child: StatusSummaryCard(
                                  title: 'In Progress',
                                  count: taskProvider.inProgressTasksCount.toString(),
                                  icon: Icons.sync_rounded,
                                  color: AppConstants.info,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              SizedBox(
                                width: cardWidth,
                                child: StatusSummaryCard(
                                  title: 'Completed',
                                  count: taskProvider.completedTasksCount.toString(),
                                  icon: Icons.check_circle_outline_rounded,
                                  color: AppConstants.success,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Search Bar & Filters Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Input Field
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search tasks by title or description...',
                              prefixIcon: const Icon(Icons.search, color: AppConstants.textSecondary),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: AppConstants.textSecondary),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppConstants.surface,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                borderSide: const BorderSide(color: AppConstants.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                borderSide: const BorderSide(color: AppConstants.border),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),

                          // Priority Filter & Sorting Controls Row
                          Wrap(
                            spacing: AppConstants.paddingMedium,
                            runSpacing: AppConstants.paddingSmall,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Priority Dropdown Filter
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Priority:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: _selectedPriority,
                                    underline: const SizedBox(),
                                    dropdownColor: AppConstants.surface,
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                                      DropdownMenuItem(value: 'high', child: Text('High Priority')),
                                      DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                                      DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedPriority = val;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // Sort Dropdown Selector
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Sort:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: _selectedSort,
                                    underline: const SizedBox(),
                                    dropdownColor: AppConstants.surface,
                                    items: const [
                                      DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                                      DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                                      DropdownMenuItem(value: 'due_earliest', child: Text('Due Date: Earliest')),
                                      DropdownMenuItem(value: 'due_latest', child: Text('Due Date: Latest')),
                                      DropdownMenuItem(value: 'priority_high_low', child: Text('Priority: High to Low')),
                                      DropdownMenuItem(value: 'priority_low_high', child: Text('Priority: Low to High')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedSort = val;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // Clear Filters Button if any filter active
                              if (_searchQuery.isNotEmpty || _selectedPriority != 'all' || _selectedSort != 'newest' || _tabController.index != 0)
                                TextButton.icon(
                                  onPressed: _clearFilters,
                                  icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                                  label: const Text('Reset Filters'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Bar for Status Filtering
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppConstants.accent,
                        unselectedLabelColor: AppConstants.textSecondary,
                        indicatorColor: AppConstants.accent,
                        tabs: const [
                          Tab(text: 'All'),
                          Tab(text: 'Pending'),
                          Tab(text: 'In Progress'),
                          Tab(text: 'Completed'),
                        ],
                      ),
                    ),
                  ),
                ];
              },

              // Main Task List View Body
              body: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Builder(
                  builder: (context) {
                    // Status Filter
                    String filterStatus = 'all';
                    switch (_tabController.index) {
                      case 1:
                        filterStatus = 'pending';
                        break;
                      case 2:
                        filterStatus = 'in_progress';
                        break;
                      case 3:
                        filterStatus = 'completed';
                        break;
                    }

                    // Multi-criteria Filtering Pipeline
                    List<TaskModel> filteredTasks = tasksList.where((task) {
                      // Status match
                      if (filterStatus != 'all' && task.status != filterStatus) {
                        return false;
                      }
                      // Priority match
                      if (_selectedPriority != 'all' && task.priority != _selectedPriority) {
                        return false;
                      }
                      // Search query match (title or description)
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        final matchesTitle = task.title.toLowerCase().contains(query);
                        final matchesDesc = task.description.toLowerCase().contains(query);
                        if (!matchesTitle && !matchesDesc) return false;
                      }
                      return true;
                    }).toList();

                    // Multi-criteria Sorting Pipeline
                    filteredTasks.sort((a, b) {
                      switch (_selectedSort) {
                        case 'oldest':
                          final da = a.createdAt ?? DateTime(2000);
                          final db = b.createdAt ?? DateTime(2000);
                          return da.compareTo(db);
                        case 'due_earliest':
                          if (a.dueDate == null && b.dueDate == null) return 0;
                          if (a.dueDate == null) return 1;
                          if (b.dueDate == null) return -1;
                          return a.dueDate!.compareTo(b.dueDate!);
                        case 'due_latest':
                          if (a.dueDate == null && b.dueDate == null) return 0;
                          if (a.dueDate == null) return 1;
                          if (b.dueDate == null) return -1;
                          return b.dueDate!.compareTo(a.dueDate!);
                        case 'priority_high_low':
                          final pw = {'high': 3, 'medium': 2, 'low': 1};
                          final wa = pw[a.priority.toLowerCase()] ?? 0;
                          final wb = pw[b.priority.toLowerCase()] ?? 0;
                          return wb.compareTo(wa);
                        case 'priority_low_high':
                          final pw = {'high': 3, 'medium': 2, 'low': 1};
                          final wa = pw[a.priority.toLowerCase()] ?? 0;
                          final wb = pw[b.priority.toLowerCase()] ?? 0;
                          return wa.compareTo(wb);
                        case 'newest':
                        default:
                          final da = a.createdAt ?? DateTime.now();
                          final db = b.createdAt ?? DateTime.now();
                          return db.compareTo(da);
                      }
                    });

                    // Loading State
                    if (taskProvider.isLoading && tasksList.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Error State
                    if (taskProvider.errorMessage != null && tasksList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: AppConstants.error),
                              const SizedBox(height: AppConstants.paddingMedium),
                              Text(
                                taskProvider.errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: AppConstants.error),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.paddingMedium),
                              ElevatedButton(
                                onPressed: () {
                                  taskProvider.fetchTasks();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Differentiated Empty State A: User has no tasks at all
                    if (tasksList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: AppConstants.textSecondary.withOpacity(0.4),
                              ),
                              const SizedBox(height: AppConstants.paddingMedium),
                              Text(
                                'No tasks yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppConstants.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Create your first task to stay organized and boost productivity.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppConstants.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.paddingLarge),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add-task');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Your First Task'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.accent,
                                  foregroundColor: AppConstants.surface,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Differentiated Empty State B: Search / Filter results returned 0
                    if (filteredTasks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt_off_outlined,
                                size: 64,
                                color: AppConstants.textSecondary.withOpacity(0.4),
                              ),
                              const SizedBox(height: AppConstants.paddingMedium),
                              Text(
                                'No matching tasks',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppConstants.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'No tasks match your selected search or filter criteria.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppConstants.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.paddingLarge),
                              OutlinedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset All Filters'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Task List View
                    return ListView.builder(
                      itemCount: filteredTasks.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.pushNamed(context, '/edit-task', arguments: task);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-task');
        },
        backgroundColor: AppConstants.accent,
        foregroundColor: AppConstants.surface,
        icon: const Icon(Icons.add),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
