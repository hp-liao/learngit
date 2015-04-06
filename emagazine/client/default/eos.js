/*!
 * HP EOS Framework HTML Integration API v1.2
 *
 * Copyright 2012 (C) Hewlett-Packard Development Company
 * All Rights Reserved.
 *
 * Date: 2012/09/06 15:30:00
 */

(function(window) {
var browser = function() {
	var ua = navigator.userAgent;
	return {
		mobile : (!!ua.match(/AppleWebKit/) || !!ua.match(/Android/)
				|| !!ua.match(/Mobile/) || !!ua.match(/MaryKayMobility/))
				&& (!ua.match(/Windows/) && !ua.match(/Macintosh/))
	};
}();

function isArray(o) {
	return Object.prototype.toString.call(o) === '[object Array]';
}

function extend() {
	var target = arguments[0] || {}, i = 1,
		length = arguments.length,
		source,
		property;

	for (; i < length; i++) {
		source = arguments[i];
		for (property in source) {
			target[property] = source[property];
		}
	}
	return target;
}

var executeLua = function(head, func, arg, sent) {
};

if (!!browser.mobile) {
	// Production mode
	var gapBridge = undefined;
	executeLua = function(head, func, arg, sent) {
		var obj = {
			head : head,
			func : func,
			arg : (typeof arg === "object") ? JSON.stringify(arg) : arg,
			sent : sent
		};
		if (gapBridge === undefined) {
			gapBridge = document.createElement("IFRAME");
			gapBridge.setAttribute("height", "0px");
			gapBridge.setAttribute("width", "0px");
			gapBridge.setAttribute("frameborder", "0");
			if (document.body) {
				document.body.appendChild(gapBridge);
			} else {
				document.addEventListener("DOMContentLoaded", function() {
					document.body.appendChild(gapBridge);
					gapBridge.src = "ftp://lua/?"
							+ encodeURIComponent(JSON.stringify(obj));
				});
				return;
			}
		}
		gapBridge.src = "ftp://lua/?"
				+ encodeURIComponent(JSON.stringify(obj));
	};
} else if (console && typeof console.dir === "function") {
	// Development mode with console
	executeLua = function(head, func, arg, sent) {
		var output = {};
		if (head) {
			output[head + ':' + func] = arg;
		} else {
			output[func] = arg;
		}
		console.dir(output);
		window.setTimeout(sent + "()", 10);
	};
} else {
	// Development mode without console
	executeLua = function(head, func, arg) {
		var obj = {
			head : head,
			func : func,
			arg : (typeof arg === "object") ? JSON.stringify(arg) : arg,
			sent : sent
		};
		alert(JSON.stringify(obj));
		window.setTimeout(sent + "()", 10);
	};
}

var IntegrationClass = function() {
};

extend(IntegrationClass, {
	taskQueue : [],
	currentTask : undefined,
	addTask : function(task) {
		if (IntegrationClass.currentTask === undefined) {
			IntegrationClass.currentTask = task;
			task();
		}
		else {
			IntegrationClass.taskQueue.push(task);
		}
	},
	nextTask : function() {
		IntegrationClass.currentTask = IntegrationClass.taskQueue.shift();
		if (IntegrationClass.currentTask !== undefined) {
			IntegrationClass.currentTask();
		}
	}
});

extend(IntegrationClass.prototype, {
	/* Basic APIs */
	extend : function(source) {
		return extend(new IntegrationClass(), source);
	},
	createCallback : function(callback, context) {
		if (typeof (callback) === "function") {
			var wrapper = {
				token : "cb_" + new Date().getTime() + "_"
						+ Math.floor(Math.random() * 10000),
				invoke : function() {
					delete eos[this.token];
					callback.apply(context, arguments);
				}
			};
			eos[wrapper.token] = wrapper;
			return "eos['" + wrapper.token + "'].invoke";
		}
		return callback;
	},
	exec : function(head, func, arg) {
		IntegrationClass.addTask(function() {
			executeLua(head, func, arg, "eos.runNext");
		});
	},
	runNext : IntegrationClass.nextTask,

	/* Navigation APIs */
	restart : function() {
		this.exec(undefined, "restart", undefined);
	},
	exit : function() {
		this.exec(undefined, "exit", undefined);
	},
	title : function(config){
		if (config) {
			this.exec(undefined, "setTitle", config);
		}
	},
	toolBar : function(config){
		if (config) {
			if (!isArray(config)){
				config = [ config ];
			}
			this.exec(undefined, "setToolBar", config);
		}
	},
	navBar : function(config) {
		if (config) {
			if (config.leftButton) {
				if (!isArray(config.leftButton)) {
					config.leftButton = [ config.leftButton ];
				}
			}
			if (config.rightButton) {
				if (!isArray(config.rightButton)) {
					config.rightButton = [ config.rightButton ];
				}
			}
			this.exec(undefined, "setNavBar", config);
		}
	},

	/* Security APIs */
	refreshProfile : function() {
		this.exec(undefined, "refreshProfile", undefined);
	},
	logout : function(message) {
		var obj = {
			message : message
		};
		this.exec(undefined, "logout", obj);
	},

	/* Device APIs */
	phone : function(number) {
		this.exec(undefined, "callNumber", number);
	},
	sms : function(numbers, message) {
		var obj = {
			numbers : numbers,
			message : message
		};
		this.exec(undefined, "smsNumber", obj);
	},

	/* Message APIs */
	showMessage : function(title, message, expireTime) {
		expireTime = parseInt(expireTime);
		if (isNaN(expireTime) || expireTime <= 0) {
			expireTime = undefined;
		}
		var obj = {
			title : title,
			message : message,
			modal : expireTime === undefined,
			expireTime : expireTime
		};
		this.exec(undefined, 'showMessage', obj);
	}
});

// Export eos to the global object.
window.eos = new IntegrationClass();
})(window);
