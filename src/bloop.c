#include "all.h"
#include "Board.h"
#include "Page.h"

static void print_board(JsonArray *array,
                        guint      index,
                        JsonNode  *elem,
                        gpointer   user_data)
{
  Board *b = json_gobject_deserialize(TYPE_BOARD, elem);
  if (b)
  {
    g_print("/%s/ ", board_get_board(b));
    g_object_unref(b);
  }
}

int main(int argc, char *argv[])
{
  SoupSession *sess = soup_session_new();
  SoupMessage *get_boards = soup_message_new("GET", "https://a.4cdn.org/boards.json");
  GInputStream *boards_json = soup_session_send(sess, get_boards, NULL, NULL);

  JsonParser *parser = json_parser_new();
  json_parser_load_from_stream(parser, boards_json, NULL, NULL);
  JsonArray *boards = json_object_get_array_member(json_node_get_object(json_parser_get_root(parser)), "boards");
  json_array_foreach_element(boards, &print_board, NULL);

  printf("\nChoose a board: ");
  char choice[5];
  fscanf(choice, sizeof choice, stdin);

  char const *url = g_strdup_printf("https://a.4cdn.org/%s/threads.json", choice);
  SoupMessage *get_threads = soup_message_new("GET", url);
  GInputStream *threads_json = soup_session_send(sess, get_threads, NULL, NULL);
  json_parser_load_from_stream(parser, threads_json, NULL, NULL);
}
