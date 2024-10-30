# Cross-Chain Resilience Scoring System

## Overview
The Cross-Chain Resilience Scoring System is a smart contract implementation designed to enhance the security and efficiency of sBTC transactions on the Stacks blockchain. By calculating and assigning resilience scores to transactions, the system enables prioritized processing of low-risk transactions while maintaining robust security measures for higher-risk ones.

## Project Structure
```
├── contracts/
│   └── resilience-scoring.clar    # Main contract implementation
├── tests/
│   └── resilience-scoring_test.clar
└── README.md
```

## Features
- Real-time transaction risk assessment
- Configurable risk factors and weights
- Normalized scoring system (0-100 scale)
- Priority transaction identification
- Administrative controls for risk factor management

## Technical Details

### Contract Components

#### Data Maps
- **TransactionScores**: Stores transaction scores and metadata
  - Key: Transaction hash (buff 32)
  - Values: 
    - score (uint)
    - timestamp (uint)
    - processed (bool)

- **RiskFactors**: Stores risk assessment parameters
  - Key: factor-id (uint)
  - Values:
    - weight (uint)
    - threshold (uint)

#### Core Functions

1. **calculate-resilience-score**
   ```clarity
   (define-public (calculate-resilience-score 
       (tx-hash (buff 32))
       (amount uint)
       (sender-history uint)
       (receiver-history uint)
       (chain-health uint))
   ```
   Calculates a resilience score based on multiple risk factors.

2. **get-transaction-score**
   ```clarity
   (define-read-only (get-transaction-score (tx-hash (buff 32)))
   ```
   Retrieves the resilience score for a specific transaction.

3. **is-high-priority**
   ```clarity
   (define-read-only (is-high-priority (tx-hash (buff 32)))
   ```
   Determines if a transaction qualifies for priority processing.

4. **set-risk-factor**
   ```clarity
   (define-public (set-risk-factor 
       (factor-id uint)
       (weight uint)
       (threshold uint))
   ```
   Administrative function to configure risk assessment parameters.

## Scoring Methodology

### Current Implementation
The scoring system evaluates transactions based on four primary factors:
1. Transaction amount
2. Sender history
3. Receiver history
4. Chain health

Each factor is weighted and combined to produce a normalized score between 0 and 100.

### Score Interpretation
- **75-100**: High priority transactions (minimal risk)
- **50-74**: Medium priority transactions (moderate risk)
- **0-49**: Low priority transactions (higher risk, requires additional verification)

## Development Roadmap

### Current Version (1.0.0)
- Basic scoring implementation
- Core data structures
- Administrative controls
- Basic risk factor management

### Planned Improvements
1. Enhanced scoring algorithms
2. Additional risk factors integration
3. Historical data analysis
4. Cross-chain verification mechanisms
5. Dynamic weight adjustments

## Security Considerations
- Contract owner authorization required for administrative functions
- Input validation for all public functions
- Error handling for edge cases
- Score normalization to prevent manipulation

## Usage

### Prerequisites
- Clarity SDK
- Stacks blockchain environment
- Bitcoin node (for sBTC integration)

### Deployment
1. Deploy the contract to the Stacks blockchain
2. Initialize risk factors using `set-risk-factor`
3. Monitor transaction scoring through provided read functions

### Integration
To integrate with existing systems:
```clarity
;; Calculate score for new transaction
(contract-call? .resilience-scoring calculate-resilience-score 
    tx-hash amount sender-history receiver-history chain-health)

;; Check transaction priority
(contract-call? .resilience-scoring is-high-priority tx-hash)
```

## Contributing
The project follows a branching strategy with comprehensive pull requests. Each improvement phase is documented and reviewed before integration.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
