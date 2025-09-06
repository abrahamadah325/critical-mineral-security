# Critical Mineral Security Smart Contracts

A comprehensive blockchain-based system for managing strategic mineral reserves and assessing supply chain risks in critical mineral operations.

## 🎯 Project Overview

This project implements a decentralized solution for tracking and managing critical minerals that are essential for national security, renewable energy, and advanced technology sectors. The smart contracts provide transparency, traceability, and risk assessment capabilities for supply chains dealing with rare earth elements, lithium, cobalt, and other strategic materials.

## 📋 Features

### Strategic Mineral Reserve Management
- **Reserve Registration**: Register and track strategic mineral reserves with location, quantity, and quality metrics
- **Reserve Monitoring**: Real-time tracking of reserve levels and consumption rates
- **Access Control**: Multi-tier authorization system for reserve access and management
- **Reserve Analytics**: Historical data tracking and trend analysis for strategic planning

### Supply Chain Risk Assessment
- **Source Verification**: Verify and authenticate mineral sources and origins
- **Risk Scoring**: Dynamic risk assessment based on geopolitical, environmental, and operational factors
- **Supply Chain Mapping**: Complete traceability from extraction to end-use
- **Alert System**: Automated notifications for supply chain disruptions and risks

### Security & Compliance
- **Immutable Records**: Blockchain-based record keeping for audit trails
- **Regulatory Compliance**: Built-in compliance checking for international trade regulations
- **Multi-signature Operations**: Enhanced security for critical operations
- **Emergency Protocols**: Automated responses to supply chain crises

## 🏗️ Architecture

The system consists of three main smart contracts:

1. **`mineral-reserve-manager.clar`** - Core reserve management functionality
2. **`supply-chain-tracker.clar`** - Supply chain monitoring and traceability
3. **`risk-assessment-engine.clar`** - Risk evaluation and scoring system

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) v1.0+
- [Node.js](https://nodejs.org/) v16+
- [Git](https://git-scm.com/)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/abrahamadah325/critical-mineral-security.git
cd critical-mineral-security
```

2. Install dependencies:
```bash
npm install
```

3. Run contract checks:
```bash
clarinet check
```

4. Run tests:
```bash
clarinet test
```

## 📚 Contract Documentation

### Mineral Reserve Manager
Handles the registration, tracking, and management of strategic mineral reserves.

**Key Functions:**
- `register-reserve` - Register a new mineral reserve
- `update-reserve-status` - Update reserve quantity and status
- `authorize-access` - Grant access permissions to reserves
- `get-reserve-info` - Retrieve reserve information

### Supply Chain Tracker
Provides end-to-end traceability for mineral supply chains.

**Key Functions:**
- `register-source` - Register a mineral source/mine
- `create-shipment` - Create a new shipment record
- `update-shipment-status` - Track shipment progress
- `verify-chain-integrity` - Validate supply chain completeness

### Risk Assessment Engine
Evaluates and scores supply chain risks based on multiple factors.

**Key Functions:**
- `calculate-risk-score` - Compute risk scores for sources/shipments
- `update-risk-factors` - Modify risk assessment parameters
- `generate-risk-report` - Create comprehensive risk assessments
- `set-alert-thresholds` - Configure automated alert triggers

## 🔧 Configuration

Contract configurations are managed through the `Clarinet.toml` file. Key settings include:

- Network configurations (mainnet, testnet, devnet)
- Contract deployment parameters
- Testing environments

## 🧪 Testing

The project includes comprehensive test suites:

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/mineral-reserve-manager_test.ts

# Run with coverage
npm run test:coverage
```

## 🔐 Security Considerations

- All critical operations require multi-signature approval
- Role-based access control ensures proper authorization
- Regular security audits recommended for production deployment
- Emergency pause functionality for critical vulnerabilities

## 🌍 Use Cases

- **Government Agencies**: Strategic reserve management for national security
- **Mining Companies**: Supply chain transparency and compliance
- **Manufacturers**: Source verification for critical components
- **Financial Institutions**: Risk assessment for commodity financing
- **Regulatory Bodies**: Monitoring and compliance enforcement

## 📊 Data Models

### Reserve Structure
- Reserve ID, Location, Mineral Type
- Quantity, Quality Grade, Access Level
- Last Updated, Creation Date
- Authorized Parties

### Supply Chain Record
- Source Information, Destination
- Transport Details, Quality Certificates
- Risk Scores, Compliance Status
- Timestamp Trail

### Risk Factors
- Geopolitical Stability Score
- Environmental Risk Level
- Transportation Security
- Market Volatility Index

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add comprehensive tests
5. Submit a pull request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Review the documentation
- Check existing discussions

## 🗺️ Roadmap

- [ ] Integration with IoT sensors for real-time monitoring
- [ ] AI-powered risk prediction models
- [ ] Cross-chain compatibility for wider adoption
- [ ] Mobile application for field operations
- [ ] Advanced analytics dashboard

---

**Note**: This system handles sensitive strategic information. Ensure proper security measures are in place before production deployment.
