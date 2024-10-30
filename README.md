# Cross-Chain Resilience Scoring System

## Overview
The Cross-Chain Resilience Scoring System is a smart contract implementation designed to enhance the security and efficiency of sBTC transactions on the Stacks blockchain. By calculating and assigning resilience scores to transactions, the system enables prioritized processing of low-risk transactions while maintaining robust security measures for higher-risk ones.

## Version History
- v1.0.0: Initial implementation with basic scoring system
- v1.1.0: Enhanced scoring algorithm with dynamic risk analysis and historical patterns

## Project Structure
```
├── contracts/
│   └── resilience-scoring.clar    # Main contract implementation
├── tests/
│   └── resilience-scoring_test.clar
└── README.md
```

## Features

### Core Features
- Real-time transaction risk assessment
- Configurable risk factors and weights
- Normalized scoring system (0-100 scale)
- Priority transaction identification
- Administrative controls for risk factor management

### New in v1.1.0
- Historical pattern analysis for addresses
- Time-window based transaction metrics
- Dynamic risk adjustment system
- Transaction velocity tracking
- Enhanced risk categorization (LOW_RISK, MEDIUM_RISK, HIGH_RISK)
- Adaptive multipliers for dynamic adjustments

## Technical Details

### Contract Components

#### Enhanced Data Maps
1. **TransactionScores**: 
   ```clarity
   {
       score: uint,
       timestamp: uint,
       processed: bool,
       risk-level: (string-utf8 20),
       velocity-factor: uint
   }
   ```

2. **RiskFactors**:
   ```clarity
   {
       weight: uint,
       threshold: uint,
       adaptive-multiplier: uint,
       last-updated: uint
   }
   ```

3. **AddressHistory** (New):
   ```clarity
   {
       total-transactions: uint,
       successful-transactions: uint,
       average-amount: uint,
       last-activity: uint
   }
   ```

4. **TimeWindowMetrics** (New):
   ```clarity
   {
       transaction-count: uint,
       average-score: uint,
       high-risk-count: uint,
       timestamp: uint
   }
   ```

### Core Functions

1. **calculate-resilience-score**
   ```clarity
   (define-public (calculate-resilience-score 
       (tx-hash (buff 32))
       (amount uint)
       (sender principal)
       (receiver principal)
       (chain-health uint))
   ```
   Enhanced scoring algorithm incorporating:
   - Historical transaction patterns
   - Address behavior analysis
   - Time-window metrics
   - Velocity risk factors

2. **New Risk Analysis Functions**:
   - `calculate-amount-risk`: Analyzes transaction amounts against historical averages
   - `calculate-address-risk`: Evaluates address reliability based on transaction history
   - `calculate-chain-health-impact`: Assesses blockchain health influence
   - `calculate-velocity-risk`: Measures transaction velocity impact
   - `adjust-score-with-patterns`: Applies pattern-based adjustments

## Scoring Methodology

### Enhanced Scoring Algorithm
The system now employs a multi-layered scoring approach:

1. **Base Score Calculation**
   - Transaction amount risk (weighted x2)
   - Sender address risk (weighted x3)
   - Receiver address risk (weighted x2)
   - Chain health impact (weighted x2)
   - Velocity risk (weighted x1)

2. **Dynamic Adjustments**
   - Historical pattern analysis
   - Time-window based adjustments
   - Velocity factor integration
   - Adaptive multipliers

### Risk Categorization
- **LOW_RISK (75-100)**: High priority processing
- **MEDIUM_RISK (50-74)**: Standard processing
- **HIGH_RISK (0-49)**: Enhanced verification required

## Pattern Recognition

### Address Patterns
- Transaction frequency analysis
- Success rate tracking
- Amount pattern recognition
- Activity timeline monitoring

### Time-Window Analysis
- Transaction velocity monitoring
- Risk distribution patterns
- High-risk transaction clustering
- Temporal pattern recognition

## Security Enhancements

### New Security Features
1. **Parameter Validation**
   - Input boundary checking
   - Adaptive multiplier limits
   - Time-window constraints

2. **Pattern-Based Protection**
   - Unusual activity detection
   - Risk pattern recognition
   - Velocity-based restrictions

## Usage

### Enhanced Integration
```clarity
;; Calculate score with new parameters
(contract-call? .resilience-scoring calculate-resilience-score 
    tx-hash amount sender receiver chain-health)

;; Update risk factors with adaptive multiplier
(contract-call? .resilience-scoring update-risk-factors 
    factor-id weight threshold adaptive-multiplier)
```

### Monitoring
New monitoring capabilities:
- Historical pattern tracking
- Time-window metrics analysis
- Velocity factor monitoring
- Risk distribution visualization

## Development Roadmap

### Completed (v1.1.0)
- ✓ Enhanced scoring algorithm
- ✓ Historical pattern analysis
- ✓ Time-window metrics
- ✓ Dynamic risk adjustments

### Planned Improvements
1. Cross-chain verification mechanisms
2. Machine learning integration
3. Advanced pattern recognition
4. Real-time risk adaptation
5. Network health correlation

## Contributing
The project follows a branching strategy with comprehensive pull requests. Each improvement phase is documented and reviewed before integration.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
