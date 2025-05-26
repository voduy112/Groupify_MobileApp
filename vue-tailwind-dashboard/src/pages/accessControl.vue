<template>
    <div class="p-6">
        <h1 class="text-2xl font-bold mb-4">UI/UX & Quản lý truy cập</h1>

        <!-- Danh sách người dùng và quyền -->
        <div class="bg-white p-4 rounded-lg shadow mb-6">
            <h2 class="text-lg font-semibold mb-2">Danh sách quyền truy cập</h2>
            <table class="w-full text-sm text-left border">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-4 py-2">Tên người dùng</th>
                        <th class="px-4 py-2">Vai trò</th>
                        <th class="px-4 py-2">Quyền</th>
                        <th class="px-4 py-2 text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="user in users" :key="user.id" class="border-t hover:bg-gray-50">
                        <td class="px-4 py-2">{{ user.name }}</td>
                        <td class="px-4 py-2">{{ user.role }}</td>
                        <td class="px-4 py-2">
                            <span v-for="permission in user.permissions" :key="permission"
                                class="bg-blue-100 text-blue-800 text-xs font-medium mr-1 px-2.5 py-0.5 rounded">
                                {{ permission }}
                            </span>
                        </td>
                        <td class="px-4 py-2 text-center space-x-2">
                            <button @click="openEdit(user)" class="text-blue-600 hover:underline">Chỉnh sửa</button>
                            <button @click="confirmDelete(user.id)" class="text-red-600 hover:underline">Xóa</button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- Cài đặt giao diện UI/UX -->
        <div class="bg-white p-4 rounded-lg shadow">
            <h2 class="text-lg font-semibold mb-2">Cài đặt giao diện (UI/UX)</h2>
            <p class="text-gray-600">Tùy chỉnh giao diện như dark mode, layout, theme... (sẽ cập nhật sau).</p>
        </div>

        <!-- Modal chỉnh sửa quyền -->
        <div v-if="editingUser" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div class="bg-white p-6 rounded-lg w-full max-w-md shadow-lg">
                <h3 class="text-lg font-semibold mb-4">Chỉnh sửa quyền - {{ editingUser.name }}</h3>

                <label class="block text-sm font-medium mb-1">Quyền:</label>
                <div class="grid grid-cols-2 gap-2 mb-4">
                    <div v-for="perm in allPermissions" :key="perm" class="flex items-center space-x-2">
                        <input type="checkbox" :id="perm" :value="perm" v-model="editingUser.permissions"
                            class="rounded border-gray-300 text-blue-600" />
                        <label :for="perm" class="text-sm">{{ perm }}</label>
                    </div>
                </div>

                <div class="flex justify-end space-x-2">
                    <button @click="saveEdit" class="px-4 py-1 bg-blue-600 text-white rounded hover:bg-blue-700">
                        Lưu
                    </button>
                    <button @click="editingUser = null" class="px-4 py-1 bg-gray-300 rounded hover:bg-gray-400">
                        Hủy
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "AccessControlPage",
    data() {
        return {
            users: [
                {
                    id: 1,
                    name: "Nguyễn Văn A",
                    role: "Admin",
                    permissions: ["dashboard", "users", "groups", "documents"],
                },
                {
                    id: 2,
                    name: "Trần Thị B",
                    role: "Editor",
                    permissions: ["documents"],
                },
            ],
            allPermissions: ["dashboard", "users", "groups", "documents", "quizzes", "reports", "settings"],
            editingUser: null,
        };
    },
    methods: {
        openEdit(user) {
            // Deep clone to avoid binding changes directly
            this.editingUser = JSON.parse(JSON.stringify(user));
        },
        saveEdit() {
            const index = this.users.findIndex((u) => u.id === this.editingUser.id);
            if (index !== -1) {
                this.users[index] = { ...this.editingUser };
            }
            this.editingUser = null;
        },
        confirmDelete(id) {
            if (confirm("Bạn có chắc muốn xóa người dùng này?")) {
                this.users = this.users.filter((u) => u.id !== id);
            }
        },
    },
};
</script>

<style scoped>
table {
    border-collapse: collapse;
}
</style>
  
