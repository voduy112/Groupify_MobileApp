import { createRouter, createWebHistory } from "vue-router";
import DashboardPage from "@/pages/dashboardPage.vue";
import AdminLogin from "@/views/Login.vue";
import DashboardLayout from "@/pages/master/dashboard.vue";
import UserPage from "@/pages/userPage.vue";
import GroupPage from "@/pages/groupPage.vue";
import DocumentPage from "@/pages/documentPage.vue";
import AccessControlPage from "@/pages/accessControl.vue";
import ReportPage from "@/pages/reportPage.vue";

const routes = [
  {
    path: "/login",
    name: "Login",
    component: AdminLogin,
  },

  {
    path: "/",
    component: DashboardLayout,
    meta: { requiresAdmin: true },
    children: [
      { path: "", redirect: "/user" },
      { path: "user", name: "user", component: UserPage },
      { path: "group", name: "group", component: GroupPage },
      { path: "document", name: "document", component: DocumentPage },
      { path: "report", name: "report", component: ReportPage },
      {
        path: "access-control",
        name: "accessControl",
        component: AccessControlPage,
      },
      {
        path: "/dashboard",
        name: "Dashboard",
        component: DashboardPage,
        meta: { requiresAuth: true },
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const rawUser = localStorage.getItem("user");
  let user = null;

  try {
    user = JSON.parse(rawUser);
  } catch (e) {
    localStorage.removeItem("user");
  }

  if (to.path === "/login") {
    return next();
  }

  if (!user) {
    return next("/login");
  }

  const requiresAdmin = to.matched.some((record) => record.meta.requiresAdmin);
  if (requiresAdmin && user.role !== "admin") {
    alert("Bạn không có quyền truy cập trang này.");
    return next(false);
  }

  next();
});

export default router;
