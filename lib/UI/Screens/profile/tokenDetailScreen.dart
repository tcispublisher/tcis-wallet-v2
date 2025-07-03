import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../receiveScreen.dart';
import '../sendScreens/sendScreen.dart';

class TokenDetailScreen extends StatelessWidget {
  final Map<String, dynamic> token;

  const TokenDetailScreen({
    super.key,
    required this.token,
  });

  String formatTotalBalance(dynamic value) {
    try {
      // Convert to double if it's a string
      double numericValue;
      if (value is String) {
        numericValue = double.tryParse(value) ?? 0.0;
      } else if (value is num) {
        numericValue = value.toDouble();
      } else {
        return "0.00";
      }

      if (numericValue == 0) {
        return "0.00";
      }

      if (numericValue < 0.0000000001) {
        return NumberFormat("0.00", "en_US").format(numericValue);
      }

      // Check if the number is whole (no decimal places)
      if (numericValue == numericValue.roundToDouble()) {
        return NumberFormat("#,##0", "en_US").format(numericValue);
      }

      // Format with up to 8 decimal places
      NumberFormat formatter = NumberFormat()
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 10;

      return formatter.format(numericValue);
    } catch (e) {
      return "Invalid balance";
    }
  }

  // Helper method to format large numbers
  String _formatNumber(dynamic value) {
    if (value == null) return 'N/A';

    final num? number = value is num ? value : double.tryParse(value.toString());
    if (number == null) return value.toString();

    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return '${number.toStringAsFixed(2)}';
  }

  // Helper method to get responsive font size
  double _responsiveFontSize(BuildContext context, {double small = 12, double medium = 14, double large = 16}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return small;
    if (width < 600) return medium;
    return large;
  }

  String _formatPrice(dynamic value) {
    if (value == null) return '0.00';
    if (value is num) return value.toStringAsFixed(2);
    final parsed = double.tryParse(value.toString()) ?? 0.0;
    return parsed.toStringAsFixed(2);
  }


  // Helper method to truncate long text for small screens
  String _truncateText(String text, {int keepLength = 6, String ellipsis = '...'}) {
    if (text.length <= keepLength * 2) return text;

    final start = text.substring(0, keepLength);
    final end = text.substring(text.length - keepLength);

    return '$start$ellipsis$end';
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 350;
    final isMediumScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.network(
              token['icon'] ?? '',
              width: 24,
              height: 24,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.error,
                  size: 24,
                  color: Colors.red,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                token['name'] ?? '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: _responsiveFontSize(context, small: 14, medium: 16, large: 18),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                token['amount'] != null ? formatTotalBalance(token['amount']) : '0.00',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10.0 : 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(context, Icons.send, 'Send', token),
                  _buildActionButton(context, Icons.call_received, 'Receive', token),
                  _buildActionButton(context, Icons.swap_calls, 'Trade', token),
                  _buildActionButton(context, Icons.add, 'Buy', token),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              title: '${token['name']} Market data Top 100',
              subtitle: '\$${_formatPrice(token['price'])} +${token['change24h']?.toStringAsFixed(2) ?? '0.00'}%',
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              title: 'Subscribe to ${token['name']} ~${token['apy']?.toStringAsFixed(2) ?? '0.00'}% APY',
              subtitle: 'Subscribe to ${token['name']} to earn high returns.',
            ),
            const SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
              child: Text(
                'History',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: _responsiveFontSize(context, small: 18, medium: 22, large: 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'No data found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
                child: Text(
                  'Block chain explorer',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: _responsiveFontSize(context, small: 12, medium: 14, large: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
              child: Text(
                'Coin info',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: _responsiveFontSize(context, small: 18, medium: 22, large: 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildTokenInfoTable(context),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
              child: Text(
                'About',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: _responsiveFontSize(context, small: 18, medium: 22, large: 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildAboutSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String subtitle}) {
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _responsiveFontSize(context, small: 12, medium: 14, large: 16),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: _responsiveFontSize(context, small: 10, medium: 12, large: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenInfoTable(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            label: 'Mainnet',
            value: token['contract'] ?? 'N/A',
          ),
          _buildInfoRow(
            context,
            label: 'Token name',
            value: token['name'] ?? 'N/A',
          ),
          _buildInfoRow(
            context,
            label: 'Contract address',
            value: _truncateText(token['network']?.toString() ?? 'N/A', keepLength: isSmallScreen ? 10 : 16),
            showCopyIcon: true,
          ),
          _buildInfoRow(
            context,
            label: 'Market cap',
            value: '\$${_formatNumber(token['marketCap'])}',
          ),
          _buildInfoRow(
            context,
            label: 'Total liquidity',
            value: '\$${_formatNumber(token['liquidity'])}',
          ),
          _buildInfoRow(
            context,
            label: 'Circulating supply',
            value: _formatNumber(token['currentSupply']),
          ),
          _buildInfoRow(
            context,
            label: 'Max supply',
            value: token['maxSupply'] == 0 ? "N/A" : _formatNumber(token['maxSupply']),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 100',
            style: TextStyle(
              color: Colors.tealAccent,
              fontSize: _responsiveFontSize(context, small: 14, medium: 16, large: 18),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            token['description'] ?? 'No description available.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: _responsiveFontSize(context, small: 12, medium: 14, large: 16),
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            label: 'Official website',
            value: _truncateText(token['officialWebsite']?.toString() ?? 'N/A'),
            showLinkIcon: true,
          ),
          _buildInfoRow(
            context,
            label: 'Whitepaper',
            value: _truncateText(token['whitePaper']?.toString() ?? 'N/A'),
            showPdfIcon: true,
          ),
          _buildInfoRow(
            context,
            label: 'Blockchain explorer',
            value: _truncateText(token['explorer']?.toString() ?? 'N/A'),
            showLinkIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required String label,
        required String value,
        bool showCopyIcon = false,
        bool showLinkIcon = false,
        bool showPdfIcon = false,
      }) {
    // Function to copy text to clipboard
    void _copyToClipboard(String text) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with fixed width (adjust percentage as needed)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: _responsiveFontSize(context, small: 12, medium: 14, large: 16),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8), // Add some spacing between label and value

          // Value with icons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Tooltip(
                    message: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: _responsiveFontSize(context, small: 12, medium: 14, large: 16),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                if (showCopyIcon) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _copyToClipboard(value),
                    child: const Icon(Icons.copy, color: Colors.grey, size: 16),
                  ),
                ],
                if (showLinkIcon) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _copyToClipboard(value),
                    child: const Icon(Icons.link, color: Colors.grey, size: 16),
                  ),
                ],
                if (showPdfIcon) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _copyToClipboard(value),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 16),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Map<String, dynamic> token) {
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Column(
      children: [
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: Colors.black,
              size: isSmallScreen ? 18 : 20,
            ),
            onPressed: () {
              if (label == 'Send') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendScreen(
                      token: token,
                      symbol: token['name'] ?? '',
                      network: token['contract'] ?? '',
                      balance: double.tryParse(token['amount']?.toString() ?? '0.00') ?? 0.00,
                      price: double.tryParse(token['price']?.toString() ?? '0.00') ?? 0.00,
                      image: token['icon'] ?? '',
                      walletAddress: token['walletReceive'],
                    ),
                  ),
                );
              } else if (label == 'Receive') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiveScreen(walletReceive: token['walletReceive'], symbol: token['name'], image: token['icon']),
                  ),
                );
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: _responsiveFontSize(context, small: 10, medium: 12, large: 14),
          ),
        ),
      ],
    );
  }
}