


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


import '../../../profile/data/models/agent_details_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../profile/presentation/view_model/agent_details_provider.dart';
import '../../../orders/presentation/view_model.dart/order_provider.dart';
import '../../../../core/helpers/online_status_toggle_card.dart';
import '../../../orders/presentation/widgets/order_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final agentProvider = context.read<AgentDetailsProvider>();

      agentProvider.fetchAgentDetails().then((_) {
        if (agentProvider.agentDetails?.employeeId != null) {
          _fetchDeliveringOrders(agentProvider.agentDetails!.employeeId!);
        }

        if (mounted) {
          setState(() {
            _initialLoad = false;
          });
        }
      });
    });
  }

  void _fetchDeliveringOrders(String employeeId) {
    context.read<OrderProvider>().fetchOrders(
          deliveryAgentStatus: "Delivering",
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider's state using Consumer
    return Container( // ✅ ADDED: Container to control background color
      color: Colors.white, // ✅ ADDED: Set background to white
      child: Consumer<AgentDetailsProvider>(
        builder: (context, agentProvider, child) {
          // Show shimmer effect on initial load
          if (_initialLoad) {
            return _buildShimmerEffect();
          }

          // Show error message if something went wrong
          if (agentProvider.error != null) {
            return Center(child: Text("Error: ${agentProvider.error}"));
          }

          // Show a message if no data is found
          if (agentProvider.agentDetails == null) {
            return const Center(child: Text("No agent data found."));
          }

          // If data is available, build the dashboard UI
          final agent = agentProvider.agentDetails!;
          final firstName = agent.fullName?.split(' ').first ?? 'Agent';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $firstName',
                      style:
                          const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Ready to deliver fashion?',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 24),
                  const OnlineStatusToggleCard(),
                  const SizedBox(height: 24),
                  const Text('My Stats',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildTodayStats(agent, "0h 0m"),
                  const SizedBox(height: 24),
                  const Text('Currently Delivering',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDeliveringOrdersSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- All other helper and shimmer widgets remain the same ---

  Widget _buildDeliveringOrdersSection() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final List<OrderModel> orders = provider.deliveringOrders();
        final bool isLoading = provider.isLoading("Delivering");

        if (isLoading && orders.isEmpty) {
          return _buildOrderListShimmer();
        }

        if (orders.isEmpty) {
          return Card(
            color: Colors.white,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  "No orders are currently being delivered.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(order: orders[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
    );
  }

  Widget _buildTodayStats(AgentDetailsModel agent, String activeTime) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${agent.completionRate?.toStringAsFixed(1) ?? '0.0'}%', // 98.5%
            'Completion',
          ),
        ),

        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(agent.rating.toString(), 'Rating')),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                agent.deliveries?.toString() ?? '0', 'Delivered')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerPlaceholder(height: 30, width: 200),
              const SizedBox(height: 8),
              _buildShimmerPlaceholder(height: 18, width: 250),
              const SizedBox(height: 24),
              _buildShimmerPlaceholder(height: 70, width: double.infinity),
              const SizedBox(height: 24),
              _buildShimmerPlaceholder(height: 22, width: 100),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildShimmerPlaceholder(height: 80)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildShimmerPlaceholder(height: 80)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildShimmerPlaceholder(height: 80)),
                ],
              ),
              const SizedBox(height: 24),
              _buildShimmerPlaceholder(height: 22, width: 220),
              const SizedBox(height: 16),
              _buildOrderListShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderListShimmer() {
    return Column(
      children: List.generate(
          2,
          (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildShimmerPlaceholder(
                    height: 150, width: double.infinity),
              )),
    );
  }

  Widget _buildShimmerPlaceholder({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}