;; Critical Mineral Security - Mineral Reserve Manager
;; Strategic mineral reserve tracking and management system

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_RESERVE (err u101))
(define-constant ERR_INSUFFICIENT_QUANTITY (err u102))
(define-constant ERR_INVALID_MINERAL_TYPE (err u103))
(define-constant ERR_ACCESS_DENIED (err u104))
(define-constant ERR_RESERVE_NOT_FOUND (err u105))
(define-constant ERR_INVALID_LOCATION (err u106))
(define-constant ERR_QUALITY_GRADE_INVALID (err u107))

;; Data Variables
(define-data-var next-reserve-id uint u1)
(define-data-var total-reserves uint u0)
(define-data-var emergency-mode bool false)

;; Data Maps
(define-map mineral-reserves uint {
    owner: principal,
    location: (string-ascii 100),
    mineral-type: (string-ascii 50),
    quantity: uint,
    quality-grade: (string-ascii 10),
    access-level: uint,
    status: (string-ascii 20),
    created-at: uint,
    last-updated: uint,
    authorized-parties: (list 20 principal)
})

(define-map reserve-access-permissions {reserve-id: uint, party: principal} {
    access-type: (string-ascii 20),
    granted-at: uint,
    granted-by: principal,
    expires-at: uint
})

(define-map mineral-type-classifications (string-ascii 50) {
    criticality-level: uint,
    strategic-importance: uint,
    availability-score: uint,
    substitution-difficulty: uint
})

(define-map authorized-operators principal {
    role: (string-ascii 30),
    permissions: uint,
    authorized-at: uint,
    authorized-by: principal
})

(define-map reserve-consumption-history {reserve-id: uint, block-height: uint} {
    quantity-consumed: uint,
    consumer: principal,
    purpose: (string-ascii 100),
    authorization-ref: (string-ascii 50)
})

(define-map location-reserves (string-ascii 100) (list 50 uint))

;; Authorization Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER))

(define-private (is-authorized-operator (operator principal))
    (is-some (map-get? authorized-operators operator)))

(define-private (has-reserve-access (reserve-id uint) (party principal))
    (let ((reserve-data (map-get? mineral-reserves reserve-id)))
        (match reserve-data
            reserve (or 
                (is-eq (get owner reserve) party)
                (is-some (index-of (get authorized-parties reserve) party))
                (is-some (map-get? reserve-access-permissions {reserve-id: reserve-id, party: party})))
            false)))

;; Read-only Functions
(define-read-only (get-reserve-info (reserve-id uint))
    (map-get? mineral-reserves reserve-id))

(define-read-only (get-reserve-count)
    (var-get total-reserves))

(define-read-only (get-emergency-status)
    (var-get emergency-mode))

(define-read-only (get-mineral-classification (mineral-type (string-ascii 50)))
    (map-get? mineral-type-classifications mineral-type))

(define-read-only (get-location-reserves (location (string-ascii 100)))
    (default-to (list) (map-get? location-reserves location)))

(define-read-only (calculate-total-quantity-by-type (mineral-type (string-ascii 50)))
    (fold calculate-type-quantity (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) u0))

(define-private (calculate-type-quantity (reserve-id uint) (total uint))
    (let ((reserve-data (map-get? mineral-reserves reserve-id)))
        (match reserve-data
            reserve (if (is-eq (get mineral-type reserve) "lithium")
                (+ total (get quantity reserve))
                total)
            total)))

(define-read-only (get-access-permissions (reserve-id uint) (party principal))
    (map-get? reserve-access-permissions {reserve-id: reserve-id, party: party}))

(define-read-only (get-consumption-history (reserve-id uint) (height uint))
    (map-get? reserve-consumption-history {reserve-id: reserve-id, block-height: burn-block-height}))

;; Public Functions
(define-public (register-mineral-reserve 
    (location (string-ascii 100))
    (mineral-type (string-ascii 50))
    (quantity uint)
    (quality-grade (string-ascii 10))
    (access-level uint))
    (let (
        (reserve-id (var-get next-reserve-id))
        (current-burn-block-height burn-block-height)
    )
    (asserts! (> (len location) u0) ERR_INVALID_LOCATION)
    (asserts! (> (len mineral-type) u0) ERR_INVALID_MINERAL_TYPE)
    (asserts! (> quantity u0) ERR_INSUFFICIENT_QUANTITY)
    (asserts! (<= access-level u5) ERR_ACCESS_DENIED)
    (asserts! (> (len quality-grade) u0) ERR_QUALITY_GRADE_INVALID)
    
    (map-set mineral-reserves reserve-id {
        owner: tx-sender,
        location: location,
        mineral-type: mineral-type,
        quantity: quantity,
        quality-grade: quality-grade,
        access-level: access-level,
        status: "active",
        created-at: current-burn-block-height,
        last-updated: current-burn-block-height,
        authorized-parties: (list tx-sender)
    })
    
    ;; Update location mapping
    (let ((current-location-reserves (get-location-reserves location)))
        (map-set location-reserves location 
            (unwrap-panic (as-max-len? (append current-location-reserves reserve-id) u50))))
    
    (var-set next-reserve-id (+ reserve-id u1))
    (var-set total-reserves (+ (var-get total-reserves) u1))
    (ok reserve-id)))

(define-public (update-reserve-status 
    (reserve-id uint)
    (new-quantity uint)
    (new-status (string-ascii 20)))
    (let ((reserve-data (unwrap! (map-get? mineral-reserves reserve-id) ERR_RESERVE_NOT_FOUND)))
        (asserts! (has-reserve-access reserve-id tx-sender) ERR_ACCESS_DENIED)
        (asserts! (not (var-get emergency-mode)) ERR_UNAUTHORIZED)
        
        (map-set mineral-reserves reserve-id 
            (merge reserve-data {
                quantity: new-quantity,
                status: new-status,
                last-updated: burn-block-height
            }))
        (ok true)))

(define-public (authorize-reserve-access 
    (reserve-id uint)
    (party principal)
    (access-type (string-ascii 20))
    (expires-at uint))
    (let ((reserve-data (unwrap! (map-get? mineral-reserves reserve-id) ERR_RESERVE_NOT_FOUND)))
        (asserts! (is-eq (get owner reserve-data) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (> expires-at burn-block-height) ERR_UNAUTHORIZED)
        
        (map-set reserve-access-permissions 
            {reserve-id: reserve-id, party: party}
            {
                access-type: access-type,
                granted-at: burn-block-height,
                granted-by: tx-sender,
                expires-at: expires-at
            })
        
        ;; Add to authorized parties list if not already present
        (let ((current-parties (get authorized-parties reserve-data)))
            (if (is-none (index-of current-parties party))
                (map-set mineral-reserves reserve-id 
                    (merge reserve-data {
                        authorized-parties: (unwrap-panic 
                            (as-max-len? (append current-parties party) u20)),
                        last-updated: burn-block-height
                    }))
                false))
        (ok true)))

(define-public (consume-from-reserve 
    (reserve-id uint)
    (quantity uint)
    (purpose (string-ascii 100))
    (authorization-ref (string-ascii 50)))
    (let ((reserve-data (unwrap! (map-get? mineral-reserves reserve-id) ERR_RESERVE_NOT_FOUND)))
        (asserts! (has-reserve-access reserve-id tx-sender) ERR_ACCESS_DENIED)
        (asserts! (>= (get quantity reserve-data) quantity) ERR_INSUFFICIENT_QUANTITY)
        (asserts! (is-eq (get status reserve-data) "active") ERR_INVALID_RESERVE)
        
        ;; Update reserve quantity
        (map-set mineral-reserves reserve-id 
            (merge reserve-data {
                quantity: (- (get quantity reserve-data) quantity),
                last-updated: burn-block-height
            }))
        
        ;; Record consumption history
        (map-set reserve-consumption-history 
            {reserve-id: reserve-id, block-height: burn-block-height}
            {
                quantity-consumed: quantity,
                consumer: tx-sender,
                purpose: purpose,
                authorization-ref: authorization-ref
            })
        
        (ok true)))

(define-public (set-mineral-classification 
    (mineral-type (string-ascii 50))
    (criticality-level uint)
    (strategic-importance uint)
    (availability-score uint)
    (substitution-difficulty uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (<= criticality-level u10) ERR_INVALID_MINERAL_TYPE)
        (asserts! (<= strategic-importance u10) ERR_INVALID_MINERAL_TYPE)
        (asserts! (<= availability-score u10) ERR_INVALID_MINERAL_TYPE)
        (asserts! (<= substitution-difficulty u10) ERR_INVALID_MINERAL_TYPE)
        
        (map-set mineral-type-classifications mineral-type {
            criticality-level: criticality-level,
            strategic-importance: strategic-importance,
            availability-score: availability-score,
            substitution-difficulty: substitution-difficulty
        })
        (ok true)))

(define-public (authorize-operator 
    (operator principal)
    (role (string-ascii 30))
    (permissions uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        
        (map-set authorized-operators operator {
            role: role,
            permissions: permissions,
            authorized-at: burn-block-height,
            authorized-by: tx-sender
        })
        (ok true)))

(define-public (set-emergency-mode (enabled bool))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (var-set emergency-mode enabled)
        (ok true)))

(define-public (transfer-reserve-ownership 
    (reserve-id uint)
    (new-owner principal))
    (let ((reserve-data (unwrap! (map-get? mineral-reserves reserve-id) ERR_RESERVE_NOT_FOUND)))
        (asserts! (is-eq (get owner reserve-data) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (not (var-get emergency-mode)) ERR_UNAUTHORIZED)
        
        (map-set mineral-reserves reserve-id 
            (merge reserve-data {
                owner: new-owner,
                last-updated: burn-block-height,
                authorized-parties: (list new-owner)
            }))
        (ok true)))

;; Initialize default mineral classifications
(map-set mineral-type-classifications "lithium" {
    criticality-level: u9,
    strategic-importance: u9,
    availability-score: u4,
    substitution-difficulty: u8
})

(map-set mineral-type-classifications "cobalt" {
    criticality-level: u8,
    strategic-importance: u8,
    availability-score: u3,
    substitution-difficulty: u7
})

(map-set mineral-type-classifications "rare-earth" {
    criticality-level: u10,
    strategic-importance: u10,
    availability-score: u2,
    substitution-difficulty: u9
})
