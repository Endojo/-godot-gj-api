extends HTTPRequest

# GameJolt Godot plugin by Ackens https://github.com/ackens/-godot-gj-api
# GameJolt API index page https://gamejolt.com/game-api/doc

export(String) var private_key
export(String) var game_id

var username_cache
var token_cache
var request_type
var busy = false

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
const BASE_URLS = { 
	user_auth         = 'users/auth/',
	user_fetch        = 'users/',
	friends           = 'friends/',
	session_open      = 'sessions/open/',
	session_ping      = 'sessions/ping/',
	session_close     = 'sessions/close/',
	session_check     = 'sessions/check/',
	trophy_fetch      = 'trophies/',
	trophy_add        = 'trophies/add-achieved/',
	trophy_remove     = 'trophies/remove-achieved/',
	scores_fetch      = 'scores/',
	scores_add        = 'scores/add/',
	scores_fetch_rank = 'scores/get_rank/',
	tables_fetch      = 'scores/tables/',
	data_fetch        = 'data-store/',
	data_set          = 'data-store/set/',
	data_update       = 'data-store/update/',
	data_remove       = 'data-store/remove/',
	data_keys_get     = 'data-store/get-keys/',
	time_fetch        = 'time/'
}

signal api_authenticated(success)
signal api_user_fetched(data)
signal api_friends_fetched(data)
signal api_session_opened(success)
signal api_session_pinged(success)
signal api_session_closed(success)
signal api_session_checked(data)
signal api_trophy_fetched(data)
signal api_trophy_set_achieved(success)
signal api_trophy_removed_achieved(success)
signal api_scores_fetched(data)
signal api_scores_added(success)
signal api_score_rank_fetched(data)
signal api_tables_fetched(data)
signal api_data_fetched(data)
signal api_data_set(success)
signal api_data_updated(new_data)
signal api_data_removed(success)
signal api_data_got_keys(data)
signal api_time_fetched(data)

signal error(error)

func _ready():
	connect("request_completed", self, '_on_HTTPRequest_request_completed')
	
func gj_api(type, parameters):
	if busy:
		emit_signal('error', 'Client is busy')
	else:
		busy = true
		var url = compose_url(type, parameters)
		request(url)
	
func auth_user(token, username):
	gj_api('user_auth/user_auth/authenticated', [token, username])
	username_cache = username
	token_cache = token
	
func fetch_user(username='', id=0):
	gj_api('user_fetch/user_fetch/user_fetched', [username, id])
	
func fetch_friends():
	gj_api('friends_fetch/friends/friends_fetched', [username_cache, token_cache])
	
func open_session():
	gj_api('sessions/session_open/session_opened', [username_cache, token_cache])
	
func ping_session():
	gj_api('sessions/session_ping/session_pinged', [username_cache, token_cache])
	
func close_session():
	gj_api('sessions/session_close/session_closed', [username_cache, token_cache])
	
func check_session():
	gj_api('sessions/session_check/session_checked', [username_cache, token_cache])
	
func fetch_trophy(achieved='', trophy_ids=0):
	gj_api('trophy_fetch/trophy/trophy_fetched', [username_cache, token_cache, achieved, trophy_ids])
	
func set_trophy_achieved(trophy_id):
	gj_api('trophy_add_remove/trophy_add/trophy_set_achieved', [username_cache, token_cache, trophy_id])
	
func remove_trophy_achieved(trophy_id):
	gj_api('trophy_add_remove/trophy_remove/trophy_removed_achieved', [username_cache, token_cache, trophy_id])
	
func fetch_scores(username='', token='', limit=0, table_id=0, better_than=0, worse_than=0):
	gj_api('scores_fetch/scores_fetch/scores_fetched', [username, token, limit, table_id, better_than, worse_than])
	
func add_score(score, sort, username='', token='', guest='', table_id=0):
	gj_api('scores_add/scores_add/scores_added', [score, sort, username, token, guest, table_id])
	
func fetch_score_rank(sort, table_id=0):
	gj_api('scores_fetch_rank/scores_fetch_rank/score_rank_fetched', [sort, table_id])
	
func fetch_tables():
	gj_api('tables_fetch/tables_fetch/tables_fetched', [])
	
func fetch_data(key, username='', token=''):
	gj_api('data_fetch/data_fetch/data_fetched', [key, username, token])
	
func set_data(key, data, username='', token=''):
	gj_api('data_set/data_set/data_set', [key, data, username, token])
	
func update_data(key, operation, value, username='', token=''):
	gj_api('data_update/data_update/data_updated', [key, operation, value, username, token])
	
func remove_data(key, username='', token=''):
	gj_api('data_remove/data_remove/data_removed', [key, username, token])
	
func get_data_keys(username='', token='', pattern=''):
	gj_api('data_keys_get/data_keys_get/data_got_keys', [username, token, pattern])
	
func fetch_time():
	gj_api('time_fetch/time_fetch/time_fetched', [])
	
func compose_url(type, parameters):
	var types = type.split('/')
	request_type = types[2]

	var final_url = "https://" if use_SSL else "http://"
	final_url += API_URL + BASE_URLS[types[1]]
	final_url += '?game_id' + str(game_id)

	var c = -1
	for parameter in PARAMETERS[types[0]]:
		c += 1
		if !str(parameters[c]).empty() and str(parameters[c]) != '0':
			final_url += parameter + str(parameters[c]).percent_encode()
	
	var s = final_url + private_key
	s = s.md5_text()
	print(final_url + '&signature=' + s)
	return final_url + '&signature=' + s
	
func get_username():
	return username_cache
	
func get_user_token():
	return token_cache

func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	if result != RESULT_SUCCESS:
		emit_signal('error', 'An error occurred processing request ' + request_type)
	
	busy = false
	emit_signal('api_' + request_type, body.get_string_from_utf8())