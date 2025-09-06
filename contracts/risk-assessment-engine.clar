;; Critical Mineral Security - Risk Assessment Engine
;; Advanced risk evaluation and scoring system for supply chain security

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_INVALID_RISK_FACTOR (err u301))
(define-constant ERR_ASSESSMENT_NOT_FOUND (err u302))
(define-constant ERR_INVALID_THRESHOLD (err u303))
(define-constant ERR_ALERT_NOT_FOUND (err u304))
(define-constant ERR_INSUFFICIENT_DATA (err u305))
(define-constant ERR_CALCULATION_ERROR (err u306))
(define-constant ERR_INVALID_REGION (err u307))
(define-constant ERR_INVALID_TIMEFRAME (err u308))

;; Data Variables
(define-data-var next-assessment-id uint u1)
(define-data-var next-alert-id uint u1)
(define-data-var global-risk-multiplier uint u100)
(define-data-var system-sensitivity uint u5)
(define-data-var total-assessments uint u0)

;; Data Maps
(define-map risk-assessments uint {
    subject-id: uint,
    subject-type: (string-ascii 30),
    assessor: principal,
    overall-risk-score: uint,
    geopolitical-score: uint,
    environmental-score: uint,
    supply-security-score: uint,
    market-volatility-score: uint,
    transportation-score: uint,
    regulatory-score: uint,
    assessment-timestamp: uint,
    validity-period: uint,
    confidence-level: uint,
    methodology: (string-ascii 50)
})

(define-map risk-factors (string-ascii 50) {
    base-weight: uint,
    volatility-factor: uint,
    historical-trend: int,
    current-value: uint,
    last-updated: uint,
    data-sources: (list 10 (string-ascii 100)),
    reliability-score: uint
})

(define-map geopolitical-risk-matrix {country: (string-ascii 50), mineral-type: (string-ascii 50)} {
    stability-index: uint,
    trade-relationship-score: uint,
    sanctions-risk: uint,
    policy-predictability: uint,
    resource-nationalism: uint,
    conflict-probability: uint,
    last-updated: uint
})

(define-map market-volatility-data {mineral-type: (string-ascii 50), timeframe: uint} {
    price-volatility: uint,
    demand-volatility: uint,
    supply-volatility: uint,
    seasonal-factors: uint,
    speculative-pressure: uint,
    inventory-levels: uint,
    calculated-at: uint
})

(define-map environmental-risk-factors {location: (string-ascii 100), risk-type: (string-ascii 50)} {
    severity-level: uint,
    probability-score: uint,
    impact-duration: uint,
    mitigation-effectiveness: uint,
    regulatory-pressure: uint,
    community-resistance: uint,
    assessed-at: uint
})

(define-map alert-configurations {alert-type: (string-ascii 50), priority: uint} {
    threshold-value: uint,
    trigger-conditions: (list 10 (string-ascii 100)),
    notification-recipients: (list 20 principal),
    escalation-timeframe: uint,
    auto-actions: (list 5 (string-ascii 100)),
    created-by: principal,
    active: bool
})

(define-map active-alerts uint {
    alert-type: (string-ascii 50),
    subject-id: uint,
    risk-score: uint,
    trigger-timestamp: uint,
    acknowledged: bool,
    acknowledged-by: principal,
    resolved: bool,
    resolution-notes: (string-ascii 500),
    priority-level: uint
})

(define-map authorized-assessors principal {
    credentials: (string-ascii 100),
    specializations: (list 10 (string-ascii 50)),
    risk-clearance-level: uint,
    assessment-count: uint,
    accuracy-rating: uint,
    authorized-at: uint
})

;; Authorization Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER))

(define-private (is-authorized-assessor (assessor principal))
    (is-some (map-get? authorized-assessors assessor)))

(define-private (has-risk-clearance (level uint))
    (let ((assessor-data (map-get? authorized-assessors tx-sender)))
        (match assessor-data
            data (>= (get risk-clearance-level data) level)
            false)))

;; Risk Calculation Functions
(define-private (calculate-weighted-score (geo-score uint) (env-score uint) (supply-score uint) 
                                         (market-score uint) (transport-score uint) (reg-score uint))
    (let ((total-weight u100))
        (/ (+ (* geo-score u25)
              (* env-score u20)
              (* supply-score u20)
              (* market-score u15)
              (* transport-score u10)
              (* reg-score u10)) total-weight)))

(define-private (normalize-risk-score (raw-score uint))
    (let ((max-possible u1000)
          (normalized (/ (* raw-score u100) max-possible)))
        (if (> normalized u100) u100 normalized)))

(define-private (apply-confidence-adjustment (score uint) (confidence uint))
    (let ((adjustment (/ (* score (- u100 confidence)) u100)))
        (- score adjustment)))

;; Read-only Functions
(define-read-only (get-risk-assessment (assessment-id uint))
    (map-get? risk-assessments assessment-id))

(define-read-only (get-risk-factor (factor-name (string-ascii 50)))
    (map-get? risk-factors factor-name))

(define-read-only (get-geopolitical-risk (country (string-ascii 50)) (mineral-type (string-ascii 50)))
    (map-get? geopolitical-risk-matrix {country: country, mineral-type: mineral-type}))

(define-read-only (get-market-volatility (mineral-type (string-ascii 50)) (timeframe uint))
    (map-get? market-volatility-data {mineral-type: mineral-type, timeframe: timeframe}))

(define-read-only (get-environmental-risk (location (string-ascii 100)) (risk-type (string-ascii 50)))
    (map-get? environmental-risk-factors {location: location, risk-type: risk-type}))

(define-read-only (get-alert-config (alert-type (string-ascii 50)) (priority uint))
    (map-get? alert-configurations {alert-type: alert-type, priority: priority}))

(define-read-only (get-active-alert (alert-id uint))
    (map-get? active-alerts alert-id))

(define-read-only (get-assessor-info (assessor principal))
    (map-get? authorized-assessors assessor))

(define-read-only (calculate-composite-risk-score 
    (subject-id uint)
    (subject-type (string-ascii 30)))
    (let (
        (geopolitical u0)
        (environmental u0)
        (supply-security u0)
        (market-volatility u0)
        (transportation u0)
        (regulatory u0)
    )
    (normalize-risk-score 
        (calculate-weighted-score geopolitical environmental supply-security 
                                 market-volatility transportation regulatory))))

;; Public Functions
(define-public (conduct-risk-assessment 
    (subject-id uint)
    (subject-type (string-ascii 30))
    (geopolitical-score uint)
    (environmental-score uint)
    (supply-security-score uint)
    (market-volatility-score uint)
    (transportation-score uint)
    (regulatory-score uint)
    (confidence-level uint)
    (methodology (string-ascii 50))
    (validity-period uint))
    (let (
        (assessment-id (var-get next-assessment-id))
        (raw-overall-score (calculate-weighted-score geopolitical-score environmental-score supply-security-score
                                                     market-volatility-score transportation-score regulatory-score))
        (adjusted-score (apply-confidence-adjustment raw-overall-score confidence-level))
        (final-score (normalize-risk-score adjusted-score))
        (current-block burn-block-height)
    )
    (asserts! (is-authorized-assessor tx-sender) ERR_UNAUTHORIZED)
    (asserts! (<= geopolitical-score u100) ERR_INVALID_RISK_FACTOR)
    (asserts! (<= environmental-score u100) ERR_INVALID_RISK_FACTOR)
    (asserts! (<= supply-security-score u100) ERR_INVALID_RISK_FACTOR)
    (asserts! (<= market-volatility-score u100) ERR_INVALID_RISK_FACTOR)
    (asserts! (<= transportation-score u100) ERR_INVALID_RISK_FACTOR)
    (asserts! (<= regulatory-score u100) ERR_INVALID_RISK_FACTOR)
    (asserts! (<= confidence-level u100) ERR_INVALID_RISK_FACTOR)
    (asserts! (> validity-period u0) ERR_INVALID_TIMEFRAME)
    
    (map-set risk-assessments assessment-id {
        subject-id: subject-id,
        subject-type: subject-type,
        assessor: tx-sender,
        overall-risk-score: final-score,
        geopolitical-score: geopolitical-score,
        environmental-score: environmental-score,
        supply-security-score: supply-security-score,
        market-volatility-score: market-volatility-score,
        transportation-score: transportation-score,
        regulatory-score: regulatory-score,
        assessment-timestamp: current-block,
        validity-period: validity-period,
        confidence-level: confidence-level,
        methodology: methodology
    })
    
    ;; Check for alert triggers
    (let ((alert-check (check-alert-triggers final-score subject-type)))
        (if alert-check
            (trigger-risk-alert assessment-id final-score "high-risk-detected")
            false))
    
    ;; Update assessor statistics
    (update-assessor-stats tx-sender)
    
    (var-set next-assessment-id (+ assessment-id u1))
    (var-set total-assessments (+ (var-get total-assessments) u1))
    (ok assessment-id)))

(define-public (update-risk-factor 
    (factor-name (string-ascii 50))
    (base-weight uint)
    (volatility-factor uint)
    (historical-trend int)
    (current-value uint)
    (data-sources (list 10 (string-ascii 100)))
    (reliability-score uint))
    (let ((current-block burn-block-height))
        (asserts! (is-authorized-assessor tx-sender) ERR_UNAUTHORIZED)
        (asserts! (has-risk-clearance u3) ERR_UNAUTHORIZED)
        (asserts! (<= base-weight u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= volatility-factor u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= current-value u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= reliability-score u100) ERR_INVALID_RISK_FACTOR)
        
        (map-set risk-factors factor-name {
            base-weight: base-weight,
            volatility-factor: volatility-factor,
            historical-trend: historical-trend,
            current-value: current-value,
            last-updated: current-block,
            data-sources: data-sources,
            reliability-score: reliability-score
        })
        (ok true)))

(define-public (update-geopolitical-matrix 
    (country (string-ascii 50))
    (mineral-type (string-ascii 50))
    (stability-index uint)
    (trade-relationship-score uint)
    (sanctions-risk uint)
    (policy-predictability uint)
    (resource-nationalism uint)
    (conflict-probability uint))
    (let ((current-block burn-block-height))
        (asserts! (is-authorized-assessor tx-sender) ERR_UNAUTHORIZED)
        (asserts! (has-risk-clearance u4) ERR_UNAUTHORIZED)
        (asserts! (<= stability-index u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= trade-relationship-score u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= sanctions-risk u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= policy-predictability u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= resource-nationalism u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= conflict-probability u100) ERR_INVALID_RISK_FACTOR)
        
        (map-set geopolitical-risk-matrix 
            {country: country, mineral-type: mineral-type}
            {
                stability-index: stability-index,
                trade-relationship-score: trade-relationship-score,
                sanctions-risk: sanctions-risk,
                policy-predictability: policy-predictability,
                resource-nationalism: resource-nationalism,
                conflict-probability: conflict-probability,
                last-updated: current-block
            })
        (ok true)))

(define-public (update-market-volatility 
    (mineral-type (string-ascii 50))
    (timeframe uint)
    (price-volatility uint)
    (demand-volatility uint)
    (supply-volatility uint)
    (seasonal-factors uint)
    (speculative-pressure uint)
    (inventory-levels uint))
    (let ((current-block burn-block-height))
        (asserts! (is-authorized-assessor tx-sender) ERR_UNAUTHORIZED)
        (asserts! (> timeframe u0) ERR_INVALID_TIMEFRAME)
        (asserts! (<= price-volatility u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= demand-volatility u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= supply-volatility u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= seasonal-factors u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= speculative-pressure u100) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= inventory-levels u100) ERR_INVALID_RISK_FACTOR)
        
        (map-set market-volatility-data 
            {mineral-type: mineral-type, timeframe: timeframe}
            {
                price-volatility: price-volatility,
                demand-volatility: demand-volatility,
                supply-volatility: supply-volatility,
                seasonal-factors: seasonal-factors,
                speculative-pressure: speculative-pressure,
                inventory-levels: inventory-levels,
                calculated-at: current-block
            })
        (ok true)))

(define-public (set-alert-threshold 
    (alert-type (string-ascii 50))
    (priority uint)
    (threshold-value uint)
    (trigger-conditions (list 10 (string-ascii 100)))
    (notification-recipients (list 20 principal))
    (escalation-timeframe uint)
    (auto-actions (list 5 (string-ascii 100))))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (<= priority u5) ERR_INVALID_THRESHOLD)
        (asserts! (<= threshold-value u100) ERR_INVALID_THRESHOLD)
        (asserts! (> escalation-timeframe u0) ERR_INVALID_TIMEFRAME)
        
        (map-set alert-configurations 
            {alert-type: alert-type, priority: priority}
            {
                threshold-value: threshold-value,
                trigger-conditions: trigger-conditions,
                notification-recipients: notification-recipients,
                escalation-timeframe: escalation-timeframe,
                auto-actions: auto-actions,
                created-by: tx-sender,
                active: true
            })
        (ok true)))

(define-public (acknowledge-alert (alert-id uint) (notes (string-ascii 500)))
    (let ((alert-data (unwrap! (map-get? active-alerts alert-id) ERR_ALERT_NOT_FOUND)))
        (asserts! (not (get acknowledged alert-data)) ERR_UNAUTHORIZED)
        
        (map-set active-alerts alert-id 
            (merge alert-data {
                acknowledged: true,
                acknowledged-by: tx-sender,
                resolution-notes: notes
            }))
        (ok true)))

(define-public (resolve-alert (alert-id uint) (resolution-notes (string-ascii 500)))
    (let ((alert-data (unwrap! (map-get? active-alerts alert-id) ERR_ALERT_NOT_FOUND)))
        (asserts! (get acknowledged alert-data) ERR_UNAUTHORIZED)
        
        (map-set active-alerts alert-id 
            (merge alert-data {
                resolved: true,
                resolution-notes: resolution-notes
            }))
        (ok true)))

(define-public (authorize-assessor 
    (assessor principal)
    (credentials (string-ascii 100))
    (specializations (list 10 (string-ascii 50)))
    (risk-clearance-level uint))
    (let ((current-block burn-block-height))
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (<= risk-clearance-level u5) ERR_UNAUTHORIZED)
        
        (map-set authorized-assessors assessor {
            credentials: credentials,
            specializations: specializations,
            risk-clearance-level: risk-clearance-level,
            assessment-count: u0,
            accuracy-rating: u100,
            authorized-at: current-block
        })
        (ok true)))

(define-public (set-global-risk-multiplier (multiplier uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (>= multiplier u50) ERR_INVALID_RISK_FACTOR)
        (asserts! (<= multiplier u200) ERR_INVALID_RISK_FACTOR)
        
        (var-set global-risk-multiplier multiplier)
        (ok true)))

;; Private Helper Functions
(define-private (check-alert-triggers (risk-score uint) (subject-type (string-ascii 30)))
    (>= risk-score u80))

(define-private (trigger-risk-alert (assessment-id uint) (risk-score uint) (alert-type (string-ascii 50)))
    (let ((alert-id (var-get next-alert-id))
          (current-block burn-block-height))
        (map-set active-alerts alert-id {
            alert-type: alert-type,
            subject-id: assessment-id,
            risk-score: risk-score,
            trigger-timestamp: current-block,
            acknowledged: false,
            acknowledged-by: tx-sender,
            resolved: false,
            resolution-notes: "",
            priority-level: u1
        })
        
        (var-set next-alert-id (+ alert-id u1))
        true))

(define-private (update-assessor-stats (assessor principal))
    (let ((assessor-data (unwrap-panic (map-get? authorized-assessors assessor))))
        (map-set authorized-assessors assessor 
            (merge assessor-data {
                assessment-count: (+ (get assessment-count assessor-data) u1)
            }))
        true))

;; Initialize default risk factors
(map-set risk-factors "supply-disruption" {
    base-weight: u30,
    volatility-factor: u15,
    historical-trend: 5,
    current-value: u60,
    last-updated: u0,
    data-sources: (list "government-reports" "industry-analysis"),
    reliability-score: u85
})

(map-set risk-factors "price-volatility" {
    base-weight: u25,
    volatility-factor: u20,
    historical-trend: 8,
    current-value: u70,
    last-updated: u0,
    data-sources: (list "market-data" "commodity-exchange"),
    reliability-score: u90
})

(map-set risk-factors "geopolitical-instability" {
    base-weight: u35,
    volatility-factor: u25,
    historical-trend: 3,
    current-value: u45,
    last-updated: u0,
    data-sources: (list "political-risk-analysis" "intelligence-reports"),
    reliability-score: u75
})
