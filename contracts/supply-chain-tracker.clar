;; Critical Mineral Security - Supply Chain Tracker
;; Complete supply chain monitoring and traceability system

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_INVALID_SOURCE (err u201))
(define-constant ERR_INVALID_SHIPMENT (err u202))
(define-constant ERR_SHIPMENT_NOT_FOUND (err u203))
(define-constant ERR_SOURCE_NOT_FOUND (err u204))
(define-constant ERR_INVALID_STATUS (err u205))
(define-constant ERR_CHAIN_INTEGRITY_FAILED (err u206))
(define-constant ERR_CERTIFICATE_INVALID (err u207))
(define-constant ERR_TRANSPORT_ERROR (err u208))

;; Data Variables
(define-data-var next-source-id uint u1)
(define-data-var next-shipment-id uint u1)
(define-data-var total-sources uint u0)
(define-data-var total-shipments uint u0)
(define-data-var system-active bool true)

;; Data Maps
(define-map mineral-sources uint {
    operator: principal,
    location: (string-ascii 100),
    source-type: (string-ascii 50),
    mineral-types: (list 10 (string-ascii 50)),
    capacity: uint,
    certification-level: uint,
    environmental-score: uint,
    geopolitical-risk: uint,
    status: (string-ascii 20),
    registered-at: uint,
    last-inspection: uint,
    compliance-certificates: (list 20 (string-ascii 100))
})

(define-map shipment-records uint {
    source-id: uint,
    destination: (string-ascii 100),
    mineral-type: (string-ascii 50),
    quantity: uint,
    quality-certificates: (list 10 (string-ascii 100)),
    transport-method: (string-ascii 30),
    carrier: principal,
    status: (string-ascii 20),
    created-at: uint,
    estimated-arrival: uint,
    actual-arrival: uint,
    chain-hash: (buff 32),
    customs-clearance: bool
})

(define-map shipment-tracking {shipment-id: uint, checkpoint: uint} {
    location: (string-ascii 100),
    timestamp: uint,
    status: (string-ascii 30),
    verified-by: principal,
    temperature: int,
    humidity: uint,
    security-seal: (string-ascii 50)
})

(define-map source-compliance-history {source-id: uint, inspection-date: uint} {
    inspector: principal,
    compliance-score: uint,
    violations: (list 10 (string-ascii 100)),
    recommendations: (list 10 (string-ascii 200)),
    next-inspection: uint
})

(define-map authorized-inspectors principal {
    credentials: (string-ascii 100),
    authorized-regions: (list 10 (string-ascii 50)),
    certification-level: uint,
    authorized-at: uint
})

(define-map chain-verification-logs {shipment-id: uint, verifier: principal} {
    verification-timestamp: uint,
    integrity-score: uint,
    verification-method: (string-ascii 50),
    anomalies-detected: (list 5 (string-ascii 100)),
    verified: bool
})

(define-map transport-carriers principal {
    name: (string-ascii 100),
    license-number: (string-ascii 50),
    safety-rating: uint,
    insurance-coverage: uint,
    specialized-equipment: (list 10 (string-ascii 50)),
    authorized-routes: (list 20 (string-ascii 100))
})

;; Authorization Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER))

(define-private (is-authorized-inspector (inspector principal))
    (is-some (map-get? authorized-inspectors inspector)))

(define-private (is-authorized-carrier (carrier principal))
    (is-some (map-get? transport-carriers carrier)))

(define-private (can-modify-source (source-id uint))
    (let ((source-data (map-get? mineral-sources source-id)))
        (match source-data
            source (or (is-eq (get operator source) tx-sender)
                      (is-contract-owner)
                      (is-authorized-inspector tx-sender))
            false)))

;; Read-only Functions
(define-read-only (get-source-info (source-id uint))
    (map-get? mineral-sources source-id))

(define-read-only (get-shipment-info (shipment-id uint))
    (map-get? shipment-records shipment-id))

(define-read-only (get-shipment-tracking (shipment-id uint) (checkpoint uint))
    (map-get? shipment-tracking {shipment-id: shipment-id, checkpoint: checkpoint}))

(define-read-only (get-source-count)
    (var-get total-sources))

(define-read-only (get-shipment-count)
    (var-get total-shipments))

(define-read-only (get-system-status)
    (var-get system-active))

(define-read-only (get-compliance-history (source-id uint) (inspection-date uint))
    (map-get? source-compliance-history {source-id: source-id, inspection-date: inspection-date}))

(define-read-only (get-chain-verification (shipment-id uint) (verifier principal))
    (map-get? chain-verification-logs {shipment-id: shipment-id, verifier: verifier}))

(define-read-only (get-carrier-info (carrier principal))
    (map-get? transport-carriers carrier))

(define-read-only (calculate-chain-integrity-score (shipment-id uint))
    (let ((shipment-data (map-get? shipment-records shipment-id)))
        (match shipment-data
            shipment (let (
                (source-data (map-get? mineral-sources (get source-id shipment)))
                (base-score u100)
            )
            (match source-data
                source (- base-score 
                    (+ (get geopolitical-risk source) 
                       (- u10 (get environmental-score source))))
                u0))
            u0)))

;; Public Functions
(define-public (register-mineral-source 
    (location (string-ascii 100))
    (source-type (string-ascii 50))
    (mineral-types (list 10 (string-ascii 50)))
    (capacity uint)
    (certification-level uint)
    (environmental-score uint)
    (geopolitical-risk uint))
    (let (
        (source-id (var-get next-source-id))
        (current-burn-block-height burn-block-height)
    )
    (asserts! (> (len location) u0) ERR_INVALID_SOURCE)
    (asserts! (> (len source-type) u0) ERR_INVALID_SOURCE)
    (asserts! (> (len mineral-types) u0) ERR_INVALID_SOURCE)
    (asserts! (> capacity u0) ERR_INVALID_SOURCE)
    (asserts! (<= certification-level u5) ERR_INVALID_SOURCE)
    (asserts! (<= environmental-score u10) ERR_INVALID_SOURCE)
    (asserts! (<= geopolitical-risk u10) ERR_INVALID_SOURCE)
    
    (map-set mineral-sources source-id {
        operator: tx-sender,
        location: location,
        source-type: source-type,
        mineral-types: mineral-types,
        capacity: capacity,
        certification-level: certification-level,
        environmental-score: environmental-score,
        geopolitical-risk: geopolitical-risk,
        status: "active",
        registered-at: current-burn-block-height,
        last-inspection: current-burn-block-height,
        compliance-certificates: (list)
    })
    
    (var-set next-source-id (+ source-id u1))
    (var-set total-sources (+ (var-get total-sources) u1))
    (ok source-id)))

(define-public (create-shipment 
    (source-id uint)
    (destination (string-ascii 100))
    (mineral-type (string-ascii 50))
    (quantity uint)
    (quality-certificates (list 10 (string-ascii 100)))
    (transport-method (string-ascii 30))
    (carrier principal)
    (estimated-arrival uint))
    (let (
        (shipment-id (var-get next-shipment-id))
        (source-data (unwrap! (map-get? mineral-sources source-id) ERR_SOURCE_NOT_FOUND))
        (chain-hash (sha256 (concat (concat (unwrap-panic (to-consensus-buff? source-id))
                                           (unwrap-panic (to-consensus-buff? quantity)))
                                   (unwrap-panic (to-consensus-buff? burn-block-height)))))
    )
    (asserts! (can-modify-source source-id) ERR_UNAUTHORIZED)
    (asserts! (> (len destination) u0) ERR_INVALID_SHIPMENT)
    (asserts! (> quantity u0) ERR_INVALID_SHIPMENT)
    (asserts! (is-authorized-carrier carrier) ERR_UNAUTHORIZED)
    (asserts! (> estimated-arrival burn-block-height) ERR_INVALID_SHIPMENT)
    (asserts! (is-eq (get status source-data) "active") ERR_INVALID_SOURCE)
    
    (map-set shipment-records shipment-id {
        source-id: source-id,
        destination: destination,
        mineral-type: mineral-type,
        quantity: quantity,
        quality-certificates: quality-certificates,
        transport-method: transport-method,
        carrier: carrier,
        status: "in-transit",
        created-at: burn-block-height,
        estimated-arrival: estimated-arrival,
        actual-arrival: u0,
        chain-hash: chain-hash,
        customs-clearance: false
    })
    
    ;; Create initial tracking checkpoint
    (map-set shipment-tracking 
        {shipment-id: shipment-id, checkpoint: u0}
        {
            location: (get location source-data),
            timestamp: burn-block-height,
            status: "departed",
            verified-by: tx-sender,
            temperature: 20,
            humidity: u50,
            security-seal: "sealed"
        })
    
    (var-set next-shipment-id (+ shipment-id u1))
    (var-set total-shipments (+ (var-get total-shipments) u1))
    (ok shipment-id)))

(define-public (update-shipment-status 
    (shipment-id uint)
    (new-status (string-ascii 20))
    (checkpoint uint)
    (current-location (string-ascii 100))
    (temperature int)
    (humidity uint)
    (security-seal (string-ascii 50)))
    (let ((shipment-data (unwrap! (map-get? shipment-records shipment-id) ERR_SHIPMENT_NOT_FOUND)))
        (asserts! (or (is-eq (get carrier shipment-data) tx-sender)
                     (is-authorized-inspector tx-sender)
                     (is-contract-owner)) ERR_UNAUTHORIZED)
        
        ;; Update shipment record
        (map-set shipment-records shipment-id 
            (merge shipment-data {
                status: new-status,
                actual-arrival: (if (is-eq new-status "delivered") 
                                  burn-block-height 
                                  (get actual-arrival shipment-data))
            }))
        
        ;; Add tracking checkpoint
        (map-set shipment-tracking 
            {shipment-id: shipment-id, checkpoint: checkpoint}
            {
                location: current-location,
                timestamp: burn-block-height,
                status: new-status,
                verified-by: tx-sender,
                temperature: temperature,
                humidity: humidity,
                security-seal: security-seal
            })
        
        (ok true)))

(define-public (verify-chain-integrity 
    (shipment-id uint)
    (verification-method (string-ascii 50)))
    (let (
        (shipment-data (unwrap! (map-get? shipment-records shipment-id) ERR_SHIPMENT_NOT_FOUND))
        (integrity-score (calculate-chain-integrity-score shipment-id))
        (anomalies (list))
    )
    (asserts! (is-authorized-inspector tx-sender) ERR_UNAUTHORIZED)
    
    (map-set chain-verification-logs 
        {shipment-id: shipment-id, verifier: tx-sender}
        {
            verification-timestamp: burn-block-height,
            integrity-score: integrity-score,
            verification-method: verification-method,
            anomalies-detected: anomalies,
            verified: (>= integrity-score u80)
        })
    
    (ok (>= integrity-score u80))))

(define-public (conduct-source-inspection 
    (source-id uint)
    (compliance-score uint)
    (violations (list 10 (string-ascii 100)))
    (recommendations (list 10 (string-ascii 200)))
    (next-inspection-date uint))
    (let ((source-data (unwrap! (map-get? mineral-sources source-id) ERR_SOURCE_NOT_FOUND)))
        (asserts! (is-authorized-inspector tx-sender) ERR_UNAUTHORIZED)
        (asserts! (<= compliance-score u100) ERR_INVALID_SOURCE)
        (asserts! (> next-inspection-date burn-block-height) ERR_INVALID_SOURCE)
        
        (map-set source-compliance-history 
            {source-id: source-id, inspection-date: burn-block-height}
            {
                inspector: tx-sender,
                compliance-score: compliance-score,
                violations: violations,
                recommendations: recommendations,
                next-inspection: next-inspection-date
            })
        
        ;; Update source last inspection
        (map-set mineral-sources source-id 
            (merge source-data {
                last-inspection: burn-block-height,
                status: (if (>= compliance-score u70) "active" "suspended")
            }))
        
        (ok true)))

(define-public (authorize-inspector 
    (inspector principal)
    (credentials (string-ascii 100))
    (authorized-regions (list 10 (string-ascii 50)))
    (certification-level uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (<= certification-level u5) ERR_UNAUTHORIZED)
        
        (map-set authorized-inspectors inspector {
            credentials: credentials,
            authorized-regions: authorized-regions,
            certification-level: certification-level,
            authorized-at: burn-block-height
        })
        (ok true)))

(define-public (register-transport-carrier 
    (carrier principal)
    (name (string-ascii 100))
    (license-number (string-ascii 50))
    (safety-rating uint)
    (insurance-coverage uint)
    (specialized-equipment (list 10 (string-ascii 50)))
    (authorized-routes (list 20 (string-ascii 100))))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (<= safety-rating u10) ERR_TRANSPORT_ERROR)
        (asserts! (> insurance-coverage u0) ERR_TRANSPORT_ERROR)
        
        (map-set transport-carriers carrier {
            name: name,
            license-number: license-number,
            safety-rating: safety-rating,
            insurance-coverage: insurance-coverage,
            specialized-equipment: specialized-equipment,
            authorized-routes: authorized-routes
        })
        (ok true)))

(define-public (update-customs-clearance 
    (shipment-id uint)
    (cleared bool)
    (clearance-documents (list 5 (string-ascii 100))))
    (let ((shipment-data (unwrap! (map-get? shipment-records shipment-id) ERR_SHIPMENT_NOT_FOUND)))
        (asserts! (is-authorized-inspector tx-sender) ERR_UNAUTHORIZED)
        
        (map-set shipment-records shipment-id 
            (merge shipment-data {
                customs-clearance: cleared,
                status: (if cleared "customs-cleared" "customs-pending")
            }))
        (ok true)))

(define-public (set-system-status (active bool))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (var-set system-active active)
        (ok true)))

(define-public (update-source-certificates 
    (source-id uint)
    (new-certificates (list 20 (string-ascii 100))))
    (let ((source-data (unwrap! (map-get? mineral-sources source-id) ERR_SOURCE_NOT_FOUND)))
        (asserts! (can-modify-source source-id) ERR_UNAUTHORIZED)
        
        (map-set mineral-sources source-id 
            (merge source-data {
                compliance-certificates: new-certificates
            }))
        (ok true)))

;; Emergency Functions
(define-public (emergency-halt-shipment (shipment-id uint))
    (let ((shipment-data (unwrap! (map-get? shipment-records shipment-id) ERR_SHIPMENT_NOT_FOUND)))
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        
        (map-set shipment-records shipment-id 
            (merge shipment-data {
                status: "emergency-halt"
            }))
        (ok true)))

(define-public (suspend-source (source-id uint))
    (let ((source-data (unwrap! (map-get? mineral-sources source-id) ERR_SOURCE_NOT_FOUND)))
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        
        (map-set mineral-sources source-id 
            (merge source-data {
                status: "suspended"
            }))
        (ok true)))
