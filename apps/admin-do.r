; 2001-02-12
; updated 2001-05-25 by earl

make object! [
	type: [embeddable system]
	interface: [none]
	doc: "stores settings, does things"
	handle: func [/l u] [
		if (not value? 'admin-section) [return ""]
		switch admin-section [
			"assocs" [
				if not users-is-master? user [
					if not users-is-associate? user [return "<i>Only associates can un/associate other users.</i>"]
					]
				switch action [
					"associate" [u: users-get-by-id id 
						u/set 'space-associate true 
						users-store u 
						if = u/get 'id user/get 'id [user/set 'space-associate true]
						return ""]
					"deassociate"  [u: users-get-by-id id
						if users-is-master? u [return "<i>Master user can't be deassociated.</i>"]
						u/set 'space-associate false 
						users-store u 
						if = u/get 'id user/get 'id [user/set 'space-associate false]
						return ""]
					]
				] 
			"user-status" [
				if not users-is-master? user [
					;if not users-is-associate? user [
						;if not = id user/get 'id [
							return "<i>Only master user can dis/enable other users.</i>"
							;]
						;]
					]
				either = id user/get 'id [
					u: user
					] [
					u: users-get-by-id id
					]
				switch action [
					"enable" [ u/erase 'disabled ]
					"disable" [
						if users-is-master? u [ return "<i>Master user can't be disabled!</i>" ]
						u/set 'disabled true
						]
					]
				users-store u
				return ""
				]
			"space-mode" [
				if not users-is-master? user [return "<i>Only the master user can change the space operation mode.</i>"]
				space-meta-set "vanilla-options" "space-mode" space-mode 
				return ""
				]
			]
		]
	]
