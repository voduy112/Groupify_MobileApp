module.exports = {
  root: true,
  env: {
    node: true,
    browser: true,
  },
  extends: [
    "plugin:vue/vue3-recommended",
    "eslint:recommended",
    "plugin:prettier/recommended", // dùng config này thay cho 'prettier'
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: "module",
  },
  globals: {
    defineProps: "readonly",
    defineEmits: "readonly",
    defineExpose: "readonly",
    withDefaults: "readonly",
  },
  rules: {
    "no-console": process.env.NODE_ENV === "production" ? "warn" : "off",
    "no-debugger": process.env.NODE_ENV === "production" ? "warn" : "off",
    "no-unused-vars": [
      "warn",
      { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
    ],

    "vue/multi-word-component-names": "off",
    "vue/no-v-html": "off",
    "vue/require-default-prop": "off",
    "vue/require-explicit-emits": "off",
    "vue/no-multiple-template-root": "off",
  },
};
