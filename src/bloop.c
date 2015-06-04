#include "all.h"
#include "Board.h"
#include "Page.h"

static void dump_json(JsonNode *n)
{
  JsonGenerator *gen = json_generator_new();
  json_generator_set_root(gen, n);
  json_generator_set_pretty(gen, true);

  GOutputStream *g_stdout = g_unix_output_stream_new(STDOUT_FILENO, FALSE);
  json_generator_to_stream(gen, g_stdout, NULL, NULL);

  g_object_unref(g_stdout);
  g_object_unref(gen);
}

static void print_board(JsonArray *array,
                        guint      index,
                        JsonNode  *elem,
                        gpointer   user_data)
{
  Board *b = BOARD(json_gobject_deserialize(TYPE_BOARD, elem));
  if (b)
  {
    printf("/%s/ ", board_get_board(b));
    g_object_unref(b);
  }
}

int main(int argc, char *argv[])
{
  SoupSession *sess = soup_session_new();
  SoupMessage *get_boards = soup_message_new("GET", "https://a.4cdn.org/boards.json");
  GInputStream *boards_json = soup_session_send(sess, get_boards, NULL, NULL);
  g_assert(boards_json);

  JsonParser *parser = json_parser_new();
  json_parser_load_from_stream(parser, boards_json, NULL, NULL);
  JsonArray *boards = json_object_get_array_member(json_node_get_object(json_parser_get_root(parser)), "boards");
  json_array_foreach_element(boards, &print_board, NULL);

  printf("\nChoose a board: ");
  char choice[5];
  fgets(choice, sizeof choice, stdin);
  choice[strlen(choice)-1] = '\0';

  if (strcmp(choice, "a") == 0)
    puts("don't be a faggot");
  else
    puts("good choice");
}
