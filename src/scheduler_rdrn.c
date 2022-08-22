/* scheduler_rdrn.c: PQSH Round Robin Scheduler */

#include "pqsh/macros.h"
#include "pqsh/scheduler.h"

#include <assert.h>

/**
 * Schedule next process using round robin policy:
 *
 *  1. If there no waiting processes, then do nothing.
 *
 *  2. Move one process from front of running queue and place in back of
 *  waiting queue.
 *
 *  3. Move one process from front of waiting queue and place in back of
 *  running queue.
 *
 * @param   s	    Scheduler structure
 **/
void scheduler_rdrn(Scheduler *s) {
    /* TODO: Implement Round Robin Policy */
}

/* vim: set expandtab sts=4 sw=4 ts=8 ft=c: */
