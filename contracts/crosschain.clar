;; Title: Cross-Chain Resilience Scoring Contract
;; Version: 1.1.0 (Branch: enhanced-scoring)
;; Description: Improved implementation with dynamic risk analysis and historical patterns

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_SCORE (err u101))
(define-constant ERR_INVALID_PARAMS (err u102))
(define-constant MIN_SCORE u0)
(define-constant MAX_SCORE u100)

;; Enhanced Data Maps
(define-map TransactionScores 
    { tx-hash: (buff 32) }
    { 
        score: uint,
        timestamp: uint,
        processed: bool,
        risk-level: (string-utf8 20),  ;; Added risk level classification
        velocity-factor: uint          ;; Added transaction velocity impact
    }
)

(define-map RiskFactors
    { factor-id: uint }
    {
        weight: uint,
        threshold: uint,
        adaptive-multiplier: uint,    ;; New adaptive multiplier for dynamic adjustment
        last-updated: uint           ;; Timestamp of last update
    }
)

;; New: Historical Pattern Storage
(define-map AddressHistory
    { address: principal }
    {
        total-transactions: uint,
        successful-transactions: uint,
        average-amount: uint,
        last-activity: uint
    }
)

;; New: Time-Window Analysis
(define-map TimeWindowMetrics
    { window-id: uint }
    {
        transaction-count: uint,
        average-score: uint,
        high-risk-count: uint,
        timestamp: uint
    }
)

;; Enhanced Public Functions
(define-public (calculate-resilience-score 
    (tx-hash (buff 32))
    (amount uint)
    (sender principal)
    (receiver principal)
    (chain-health uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        
        ;; Get historical data
        (let (
            (sender-history (get-or-init-history sender))
            (receiver-history (get-or-init-history receiver))
            (time-window-stats (get-current-window-stats))
            )
            
            ;; Calculate base score with enhanced factors
            (let ((base-score (+ 
                (* (calculate-amount-risk amount sender-history) u2)
                (* (calculate-address-risk sender-history) u3)
                (* (calculate-address-risk receiver-history) u2)
                (* (calculate-chain-health-impact chain-health) u2)
                (* (calculate-velocity-risk time-window-stats) u1)
                )))
                
                ;; Apply dynamic risk adjustments
                (let ((adjusted-score (adjust-score-with-patterns 
                    base-score 
                    sender-history 
                    receiver-history
                    time-window-stats)))
                    
                    ;; Update historical data
                    (update-address-history sender amount)
                    (update-time-window-metrics adjusted-score)
                    
                    ;; Store final score
                    (map-set TransactionScores
                        { tx-hash: tx-hash }
                        {
                            score: adjusted-score,
                            timestamp: block-height,
                            processed: false,
                            risk-level: (categorize-risk adjusted-score),
                            velocity-factor: (get transaction-count time-window-stats)
                        }
                    )
                    (ok adjusted-score)
                )
            )
        )
    )
)

;; New Helper Functions
(define-private (calculate-amount-risk (amount uint) (history (optional {total-transactions: uint, successful-transactions: uint, average-amount: uint, last-activity: uint})))
    (let ((avg-amount (default-to u0 (get average-amount history))))
        (if (> amount (* avg-amount u2))
            (- MAX_SCORE (/ amount avg-amount))
            (+ MIN_SCORE (/ amount avg-amount))
        )
    )
)

(define-private (calculate-address-risk (history (optional {total-transactions: uint, successful-transactions: uint, average-amount: uint, last-activity: uint})))
    (let ((success-rate (/ 
            (* (default-to u0 (get successful-transactions history)) u100)
            (default-to u1 (get total-transactions history))
        )))
        success-rate
    )
)

(define-private (calculate-chain-health-impact (health uint))
    (if (> health u80)
        (* health u2)
        (/ health u2)
    )
)

(define-private (calculate-velocity-risk (window-stats {transaction-count: uint, average-score: uint, high-risk-count: uint, timestamp: uint}))
    (let ((velocity-factor (/ 
            (* (get transaction-count window-stats) u100)
            (- block-height (get timestamp window-stats))
        )))
        velocity-factor
    )
)

(define-private (adjust-score-with-patterns
    (base-score uint)
    (sender-history (optional {total-transactions: uint, successful-transactions: uint, average-amount: uint, last-activity: uint}))
    (receiver-history (optional {total-transactions: uint, successful-transactions: uint, average-amount: uint, last-activity: uint}))
    (time-window-stats {transaction-count: uint, average-score: uint, high-risk-count: uint, timestamp: uint}))
    (let ((pattern-multiplier (+ 
            (if (> (get high-risk-count time-window-stats) u5) u80 u100)
            (if (> (default-to u0 (get total-transactions sender-history)) u100) u10 u0)
        )))
        (/ (* base-score pattern-multiplier) u100)
    )
)

;; Utility Functions
(define-private (categorize-risk (score uint))
    (if (>= score u75)
        "LOW_RISK"
        (if (>= score u50)
            "MEDIUM_RISK"
            "HIGH_RISK"
        )
    )
)

(define-private (get-or-init-history (address principal))
    (default-to
        {
            total-transactions: u0,
            successful-transactions: u0,
            average-amount: u0,
            last-activity: block-height
        }
        (map-get? AddressHistory { address: address })
    )
)

;; Administrative Functions
(define-public (update-risk-factors 
    (factor-id uint)
    (weight uint)
    (threshold uint)
    (adaptive-multiplier uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (and (> weight u0) (< adaptive-multiplier u200)) ERR_INVALID_PARAMS)
        (map-set RiskFactors
            { factor-id: factor-id }
            {
                weight: weight,
                threshold: threshold,
                adaptive-multiplier: adaptive-multiplier,
                last-updated: block-height
            }
        )
        (ok true)
    )
)