extends HTTPRequest

# GameJolt Godot plugin by Ackens https://github.com/ackens/-godot-gj-api
# GameJolt API index page https://gamejolt.com/game-api/doc

export(String) var private_key
export(String) var game_id

# Queue elements: {cmd, args, callback}
# where cmd is one of the API_COMMANDs, args are its arguments
# and callback is an (optional) user callback to recieve the response
var queue = []

# If true all called URLs are printed
export(bool) var debug = false

# To use SSL you need to include the according certificates into your Godot project.
# They are found in the Godot repro: https://raw.githubusercontent.com/godotengine/godot/master/thirdparty/certs/ca-certificates.crt
export(bool) var use_SSL = true
const API_URL = 'api.gamejolt.com/api/game/v1_2/'

# https://gamejolt.com/game-api/doc
# All of this is sorted after the official documentation (Dec. 2018)
# Rem.: username / token is omitted in function signatures since only the user_token of the cached user is known
#       function signatures are ordered as in the documentation except when optional args are moved to the right
const API_COMMAND = {

#	Data-store          Manipulate items in a cloud-based data storage.
	data_fetch        = ['data-store/',               ['key', 'username', 'user_token']]
	data_keys_get     = ['data-store/get-keys/',      ['pattern', 'username', 'user_token']]
	data_remove       = ['data-store/remove/',        ['key', 'username', 'user_token']]
	data_set          = ['data-store/set/',           ['key', 'data', 'username', 'user_token']]
	data_update       = ['data-store/update/',        ['key', 'username', 'user_token', 'operation', 'value']]

#	Time	            Get the server's time.
	time_fetch        = ['time/',                     []]

#	Scores	            Manipulate scores on score tables.
	scores_add        = ['scores/add/',               ['username', 'user_token', 'guest', 'score', 'sort', 'extra_data', 'table_id']]
	scores_fetch_rank = ['scores/get_rank/',          ['sort', 'table_id']]
	scores_fetch      = ['scores/',                   ['limit', 'table_id', 'username', 'user_token', 'guest', 'better_than', 'worse_than']]
	tables_fetch      = ['scores/tables/',            []]

#	Sessions	        Set up sessions for your game.
	session_open      = ['sessions/open/',            ['username', 'user_token']]
	session_ping      = ['sessions/ping/',            ['username', 'user_token', 'status']]
	session_check     = ['sessions/check/',           ['username', 'user_token']]
	session_close     = ['sessions/close/',           ['username', 'user_token']]

#	Trophies	        Manage trophies for your game.
	trophy_fetch      = ['trophies/',                 ['username', 'user_token', 'achieved', 'trophy_id']]
	trophy_add        = ['trophies/add-achieved/',    ['username', 'user_token', 'trophy_id']]
	trophy_remove     = ['trophies/remove-achieved/', ['username', 'user_token', 'trophy_id']]

#	Users	            Access user-based features.
	user_auth         = ['users/auth/',               ['username', 'user_token']]
	user_fetch        = ['users/',                    ['username', 'user_id']]

#	Friends	            List a user's friends.
	friends           = ['friends/',                  ['username', 'user_token']]
}

signal error(error)

func _ready():
	connect("request_completed", self, '_on_HTTPRequest_request_completed')


var _username = null
var _user_token = null

func get_username():
	return _username
	
func get_user_token():
	return _user_token

	
func fetch_data(key):
	# returns data stored for this game (and user if set)
	gj_api(API_COMMAND.data_fetch, [key, _username, _user_token])

func get_data_keys(pattern=null):
	# returns all keys or limited to a given user or by a pattern
	gj_api(API_COMMAND.data_keys_get, [pattern, _username, _user_token])

func remove_data(key):
	# removes data for this game (and user if set)
	gj_api(API_COMMAND.data_remove, [key, _username, _user_token])	
	
func set_data(key, data):
	# stores data for this game (and user if set)
	gj_api(API_COMMAND.data_set, [key, data, _username, _user_token])
	
func update_data(key, operation, value):
	# operates on already set data: add / subtract / multiply / divide / append / prepend
	gj_api(API_COMMAND.data_update, [key, _username, _user_token, operation, value])

	
func fetch_time():
	# returns the time of the GameJolt server
	gj_api(API_COMMAND.time_fetch, [])

	
func add_score(score, sort, guest=null, extra_data=null, table_id=null):
	# adds a score, pass either username/token or guest. uses the main table if no id provided
	if guest:
		gj_api(API_COMMAND.scores_add, [null, null, guest, score, sort, extra_data, table_id])
	else:
		gj_api(API_COMMAND.scores_add, [_username, _user_token, null, score, sort, extra_data, table_id])
	
func fetch_score_rank(sort, table_id=null):
	# retrieves the rank of the nearest score
	gj_api(API_COMMAND.scores_fetch_rank, [sort, table_id])

func fetch_scores(limit=null, table_id=null, guest=null, better_than=null, worse_than=null):
	# returns scores, all arguments are optional
	if guest:
		gj_api(API_COMMAND.scores_fetch, [limit, table_id, null, null, guest, better_than, worse_than])
	else:
		gj_api(API_COMMAND.scores_fetch, [limit, table_id, _username, _user_token, null, better_than, worse_than])
	
func fetch_tables():
	# fetches the ids of all tables for this game
	gj_api(API_COMMAND.tables_fetch, [])


func open_session():
	# opens a game session for the cached user
	gj_api(API_COMMAND.session_open, [_username, _user_token])

func ping_session(status=null):
	# call at least every 120s to keep session opened, optionally status can be 'active' or 'idle'
	gj_api(API_COMMAND.session_ping, [_username, _user_token, status])
	
func check_session():
	# checks if there is an open session in this game for the cached user
	gj_api(API_COMMAND.session_check, [_username, _user_token])
	
func close_session():
	# closes the game session for the cached user
	gj_api(API_COMMAND.session_close, [_username, _user_token])

	
func fetch_trophy(achieved=null, trophy_id=null):
	# returns (only achieved) trophie(s if comma seperated list) for the cached user
	gj_api(API_COMMAND.trophy, [_username, _user_token, achieved, trophy_id])
	
func set_trophy_achieved(trophy_id):
	# gives the cached user the specified trophy
	gj_api(API_COMMAND.trophy_add, [_username, _user_token, trophy_id])
	
func remove_trophy_achieved(trophy_id):
	# removes teh specified trophy from the cached user
	gj_api(API_COMMAND.trophy_remove, [_username, _user_token, trophy_id])


func auth_user(username, user_token):
	# checks if the credentials are correct and chaches them
	_username = username
	_user_token = user_token
	gj_api(API_COMMAND.user_auth, [_username, user_token])
	
func fetch_user(username=null, user_id=null):
	# returns a user's data - only username or user_id is required
	gj_api(API_COMMAND.user_fetch, [_username, user_id])


func fetch_friends():
	# returns all friends of the cached user
	gj_api(API_COMMAND.friends, [_username, _user_token])



# use like: callback(this, '_my_callback').some_api_func(...)
# or as two subsequent calls (but setting the callback first)
# this function has no effect until the next gj_api() call is done
var user_callback = null
func callback(instance, funcname):
	user_callback = funcref(instance, funcname)
	return self


func gj_api(cmd, args):
	# using a queue we don't have to throw errors when busy
	var busy = !queue.empty()
	queue.append({cmd: cmd, args: args, callback: user_callback})
	user_callback = null

	if !busy:
		execute_next()


func execute_next():
	var what = queue.front()
	var url = compose_url(what.cmd, what.args)
	request(url)
	

func compose_url(cmd, args):
	var url = "https://" if use_SSL else "http://"
	url += API_URL + cmd[0] + '?game_id' + str(game_id)

	for i in range(cmd[1].size()):
		if args[i] != null:
			url += '&' + cmd[1][i] '=' + str(args[i]).percent_encode()
	
	url += '&signature=' + (url + private_key).md5_text()
	
	if debug:
		print(url + '&signature=' + s)
		return url + '&signature=' + s
	
	return url


func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	if result != RESULT_SUCCESS:
		emit_signal('error', 'An error occurred processing request ' + request_type)

	# this request is completed, call callback if there is any and start the next request
	var callback = queue.front().callback
	queue.pop_front()

	if callback:
		callback.call_func(body.get_string_from_utf8())
	
	if !queue.empty():
		execute_next()