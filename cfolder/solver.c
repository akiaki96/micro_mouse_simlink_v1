typedef enum{
    ACT_FORWARD,
    ACT_LEFT,
    ACT_RIGHT,
    ACT_BACK
} Action;


void solver(int front, int left, int right, int trigger, int *action);

void solver(int front, int left, int right, int trigger, int *action)
{
    if(!trigger) return;

    if(!left) *action = 1;
    else if(!front) *action = 0;
    else if(!right) *action = 2;
    else *action = 3;

}