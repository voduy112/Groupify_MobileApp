import { createRouter, createWebHistory } from "vue-router";
import dashboard from '../pages/master/dashboard.vue';
import userPage from "../pages/userPage.vue"; 
import quiz from "../pages/quiz.vue";
import group from "../pages/group.vue";
import document from "../pages/document.vue";
import accessControl from "@/pages/accessControl.vue";

const routes = [
  {
    name: "Dashboard",
    path: '/',
    component: dashboard,
    children: [
      {
        name: "user",
        path: 'user',
        component: userPage
      },
      {
        name: "quiz",
        path: 'quiz',
        component: quiz
      },
      {
        name: "group",
        path: 'group',
        component: group
      },
      {
        name: "document",
        path: 'document',
        component: document
      },
      {
        name: "accessControl",
        path: 'access-control',
        component: accessControl
      },
    ]
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
