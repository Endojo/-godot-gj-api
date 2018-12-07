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

const PARAMETERS = {
	user_auth         = ['&user_token=', '&username='],
	user_fetch        = ['&username=', '&user_id='],
	friends_fetch     = ['&username=', '&user_token='],
	sessions          = ['&username=', '&user_token='],
	trophy_fetch      = ['&username=', '&user_token=', '&achieved=', '&trophy_id='],
	trophy_add_remove = ['&username=', '&user_token=', '&trophy_id='],
	scores_fetch      = ['&username=', '&user_token=', '&limit=', '&table_id=', '&better_than=', '&worse_than='],
	scores_add        = ['&score=', '&sort=', '&username=', '&user_token=', '&guest=', '&table_id='],
	scores_fetch_rank = ['&sort=', '&table_id='],
	tables_fetch      = [],
	data_fetch        = ['&key=', '&username=', '&user_token='],
	data_set          = ['&key=', '&data=', '&username=', '&user_token='],
	data_update       = ['&key=', '&operation=', '&value=', '&username=', '&user_token='],
	data_remove       = ['&key='],
	data_keys_get     = ['&username=', '&user_token=', '&pattern='],
	time_fetch        = []
}
const API_COMMAND = { 
	user_auth         = ['users/auth/',               PARAMETERS.user_auth]
	user_fetch        = ['users/',                    PARAMETERS.user_fetch]
	friends           = ['friends/',                  PARAMETERS.friends_fetch]
	session_open      = ['sessions/open/',            PARAMETERS.sessions]
	session_ping      = ['sessions/ping/',            PARAMETERS.sessions]
	session_close     = ['sessions/close/',           PARAMETERS.sessions]
	session_check     = ['sessions/check/',           PARAMETERS.sessions]
	trophy_fetch      = ['trophies/',                 PARAMETERS.trophy_fetch]
	trophy_add        = ['trophies/add-achieved/',    PARAMETERS.trophy_add_remove]
	trophy_remove     = ['trophies/remove-achieved/', PARAMETERS.trophy_add_remove]
	scores_fetch      = ['scores/',                   PARAMETERS.scores_fetch]
	scores_add        = ['scores/add/',               PARAMETERS.scores_add]
	scores_fetch_rank = ['scores/get_rank/',          PARAMETERS.scores_fetch_rank]
	tables_fetch      = ['scores/tables/',            PARAMETERS.tables_fetch]
	data_fetch        = ['data-store/',               PARAMETERS.data_fetch]
	data_set          = ['data-store/set/',           PARAMETERS.data_set]
	data_update       = ['data-store/update/',        PARAMETERS.data_update]
	data_remove       = ['data-store/remove/',        PARAMETERS.data_remove]
	data_keys_get     = ['data-store/get-keys/',      PARAMETERS.data_keys_get]
	time_fetch        = ['time/',                     PARAMETERS.time_fetch]
}

signal error(error)

func _ready():
	connect("request_completed", self, '_on_HTTPRequest_request_completed')


var username_cache
var token_cache

func get_username():
	return username_cache
	
func get_user_token():
	return token_cache
	
# checks if the credentials are correct and chaches them
func auth_user(token, username):
	gj_api(API_COMMAND.user_auth, [token, username])
	username_cache = username
	token_cache = token
	
# returns a user's data - only username or user_id is required
func fetch_user(username=null, id=null):
	gj_api(API_COMMAND.user_fetch, [username, id])
	
# returns all friends of the cached user
func fetch_friends():
	gj_api(API_COMMAND.friends, [username_cache, token_cache])
	
# opens a game session for the cached user
func open_session():
	gj_api(API_COMMAND.session_open, [username_cache, token_cache])
	
# call at least every 120s to keep session opened
func ping_session():
	gj_api(API_COMMAND.session_ping, [username_cache, token_cache])
	
# closes the game session for the cached user
func close_session():
	gj_api(API_COMMAND.session_close, [username_cache, token_cache])
	
# checks if there is an open session in this game for the cached user
func check_session():
	gj_api(API_COMMAND.session_check, [username_cache, token_cache])
	
# returns (only achieved) trophies (with given id / ids) for the cached user
func fetch_trophy(achieved=null, trophy_ids=null):
	gj_api(API_COMMAND.trophy, [username_cache, token_cache, achieved, trophy_ids])
	
# gives the cached user the specified trophy
func set_trophy_achieved(trophy_id):
	gj_api(API_COMMAND.trophy_add, [username_cache, token_cache, trophy_id])
	
# removes teh specified trophy from the cached user
func remove_trophy_achieved(trophy_id):
	gj_api(API_COMMAND.trophy_remove, [username_cache, token_cache, trophy_id])
	
# returns scores, all arguments are optional, but pass either username/token or guest; better_than or worse_than
func fetch_scores(username=null, token=null, limit=null, table_id=null, better_than=null, worse_than=null):
	gj_api(API_COMMAND.scores_fetch, [username, token, limit, table_id, better_than, worse_than])
	
# adds a score, pass either username/token or guest. uses the main table if no id provided
func add_score(score, sort, username=null, token=null, guest=null, table_id=null):
	gj_api(API_COMMAND.scores_add, [score, sort, username, token, guest, table_id])
	
# retrieves the rank of the nearest score
func fetch_score_rank(sort, table_id=null):
	gj_api(API_COMMAND.scores_fetch_rank, [sort, table_id])
	
# fetches the ids of all tables for this game
func fetch_tables():
	gj_api(API_COMMAND.tables_fetch, [])
	
# returns data stored for this game (and user if set)
func fetch_data(key, username=null, token=null):
	gj_api(API_COMMAND.data_fetch, [key, username, token])
	
# stores data for this game (and user if set)
func set_data(key, data, username=null, token=null):
	gj_api(API_COMMAND.data_set, [key, data, username, token])
	
# operates on already set data: add / subtract / multiply / divide / append / prepend
func update_data(key, operation, value, username=null, token=null):
	gj_api(API_COMMAND.data_update, [key, operation, value, username, token])
	
# removes data for this game (and user if set)
func remove_data(key, username=null, token=null):
	gj_api(API_COMMAND.data_remove, [key, username, token])
	
# returns all keys or limited to a given user or by a pattern
func get_data_keys(username=null, token=null, pattern=null):
	gj_api(API_COMMAND.data_keys_get, [username, token, pattern])
	
# returns the time of the GameJolt server
func fetch_time():
	gj_api(API_COMMAND.time_fetch, [])
		return url


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
	

func compose_url(api_command, parameters):
	var url = "https://" if use_SSL else "http://"
	url += API_URL + command + '?game_id' + str(game_id)

	for i in range(api_command[1].size()):
		if parameters[i] != null:
			url += api_command[1][i] + str(parameters[i]).percent_encode()
	
	url += '&signature=' + (url + private_key).md5_text()
	
	if debug:
		print(url + '&signature=' + s)
		return url + '&signature=' + s


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