(use-trait nft .nft-trait.nft-trait)

%s

(define-data-var flag bool false)


(define-data-var deal bool false)


(define-constant deal-closed (err u300))
(define-constant cannot-escrow-nft (err u301))
(define-constant cannot-escrow-stx (err u302))
(define-constant sender-already-confirmed (err u303))
(define-constant non-tradable-agent (err u304))
(define-constant release-escrow-failed (err u305))


;; u501 - Progress ; u502 - Cancelled ; u503 - Finished
(define-data-var contract-status uint u501)


(define-read-only (check-contract-status)
	(ok (var-get contract-status))
)

(define-private (check-deal)
	(if (and %s true)
		(ok true)
		(ok false)
	)
)

(define-private (check-deal-status)
	(unwrap-panic
		(if (and %s)
			deal-closed
			(ok true)
		)
	)
)

(define-private (release-escrow)
	(begin
        
%s

		(var-set deal true)
		(var-set contract-status u503)
		(ok true)
	)
)

(define-private (cancel-escrow)
	(begin
        
%s

		(var-set contract-status u502)
		(ok true)
	)
)

(define-public (confirm-and-escrow)
	(begin
		(var-set flag false)
		(unwrap-panic
			(begin

%s

				(ok true)
			)
		)
		(if (and %s true)
			(begin
				(unwrap-panic
					(release-escrow)
				)
			)
			true
		)
		(if (is-eq (var-get flag) true)
			(ok true)
			non-tradable-agent
		)
	)
)

(define-public (cancel)
	(begin
		(check-deal-status)
		(if (or %s)
			(begin
				(unwrap-panic
					(cancel-escrow)
				)
				(ok true)
			)
			(ok false)
		)
	)
)

