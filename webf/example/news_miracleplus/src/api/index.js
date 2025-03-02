import { useUserStore } from '@/stores/userStore'

const getAnonymousId = () => {
    const STORAGE_KEY = 'mp_anonymous_id';
    let id = localStorage.getItem(STORAGE_KEY);
    
    if (!id) {
      id = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        const r = Math.random() * 16 | 0;
        const v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
      });
      localStorage.setItem(STORAGE_KEY, id);
    }
    
    return id;
  };
// Base configuration
const BASE_URL = 'https://api.news.miracleplus.com';

// Request headers configuration
const DEFAULT_HEADERS = {
  'Content-Type': 'application/json',
};

// Common response handler
const handleResponse = async (response) => {
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  const data = await response.json();
  // API returns { message: string, request_id: string, success: boolean }
  // success=false only indicates the result content, not request failure
  return data;
};

// Request wrapper
const request = async (endpoint, options = {}) => {
  try {
    const { headers = {}, requireAuth = false, ...restOptions } = options;
    
    // 获取用户store
    const userStore = useUserStore();
    
    // 构建请求头
    const finalHeaders = {
      ...DEFAULT_HEADERS,
      'Anonymous-Id': getAnonymousId(),
      ...headers,
    };

    // 如果需要认证或用户已登录，添加认证信息
    if (requireAuth) {
      if (!userStore.isLoggedIn) {
        console.log('This API requires authentication');
        window.webf.hybridHistory.pushState({}, '/login');
        return;
      }
      finalHeaders['Authorization'] = `Bearer ${userStore.userInfo.token}`;
    }

    // 处理请求体
    if (restOptions.body) {
      const bodyObj = JSON.parse(restOptions.body);
      bodyObj.anonymous_id = bodyObj.anonymous_id || getAnonymousId();
      restOptions.body = JSON.stringify(bodyObj);
    }

    const response = await fetch(`${BASE_URL}${endpoint}`, {
      headers: finalHeaders,
      ...restOptions,
    });
    return await handleResponse(response);
  } catch (error) {
    console.error('API request failed:', error);
    throw error;
  }
};

// API endpoints
export const api = {
  // Auth APIs
  auth: {
    loginByPhonePassword: (data) => request('/v1/users/login_by_phone_password', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
    loginByPhoneCode: (data) => request('/v1/users/login_by_phone_code', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
    register: (data) => request('/v1/users', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
    getUserInfo: () => request('/v1/users/user_info', {
      requireAuth: true,
    }),
    sendVerifyCode: (data) => request('/v1/users/sms_send', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
    logout: () => request('/v1/users/user_info', {
      requireAuth: false,
    }),
    getUserFeedsList: ({ page = 1, category = 'all', userId = '' } = {}) => 
      request(`/v1/users/${userId}/feeds?page=${page}&category=${category}`, {
        requireAuth: true,
    }),
    getUserNotifications: ({ page = 1 } = {}) => 
      request(`/v1/notifications?page=${page}`, {
        requireAuth: true,
    }),
  },

  // News APIs
  news: {
    getHotList: ({ page = 1 } = {}) => request(`/v1/feeds/hot?page=${page}`),
    getLatestList: ({ page = 1 } = {}) => request(`/v1/feeds/latest?page=${page}`),
    getCommentList: ({ page = 1 } = {}) => request(`/v1/feeds/comment?page=${page}`),
    getDisplayList: ({ page = 1, topic = '' } = {}) => 
      request(`/v1/displays?page=${page}&topic=${topic}`),
    getDetail: (id) => request(`/v1/share_links/${id}`),
    publish: (data) => request('/news/publish', {
      method: 'POST',
      body: JSON.stringify(data),
      requireAuth: true,
    }),
  },

  // Comment APIs
  comments: {
    getList: ({ page = 1, resourceId = '', resourceType = 'ShareLink'} = {}) => 
      request(`/v1/comments?page=${page}&resource_id=${resourceId}&resource_type=${resourceType}`),
    create: (data) => request('/comments', {
      method: 'POST',
      body: JSON.stringify(data),
      requireAuth: true,
    }),
  },

  // User APIs
  user: {
    getFeeds: ({ page = 1, category = 'all', userId = '' } = {}) => request(`/v1/users/${userId}/feeds?page=${page}&category=${category}`, {
        requireAuth: true,
    }),
  },
  search: {
    users: ({ keyword = '', perPage = 10 } = {}) => request(`/v1/users/search?keyword=${keyword}&per_page=${perPage}`, {
        requireAuth: true,
    }),
    answers: ({ keyword = '', perPage = 10 } = {}) => request(`/v1/answers/search?keyword=${keyword}&per_page=${perPage}`, {
        requireAuth: true,
    }),
    questions: ({ keyword = '', perPage = 10 } = {}) => request(`/v1/questions/search?keyword=${keyword}&per_page=${perPage}`, {
        requireAuth: true,
    }),
    shareLinks: ({ keyword = '', perPage = 10 } = {}) => request(`/v1/share_links/search?keyword=${keyword}&per_page=${perPage}`, {
        requireAuth: true,
    }),
  },
  question: {
    getDetail: (id) => request(`/v1/questions/${id}`, { 
        requireAuth: true,
    }),
    getAnswerDetail: (id) => request(`/v1/answers/${id}`, {
      requireAuth: true,
    }),
  },
  topic: {
    getDetail: (id) => request(`/v1/topics/${id}`, {
      requireAuth: true,
    }),
  }
};

// Usage example:
/*
try {
  // Get news list
  const newsList = await api.news.getList({ page: 1, limit: 10 });
  
  // Login
  const userData = await api.auth.login({ 
    username: 'user', 
    password: 'pass' 
  });
  
  // Publish news
  const publishResult = await api.news.publish({
    title: 'News Title',
    content: 'News Content'
  });
} catch (error) {
  // Handle error
  console.error('Operation failed:', error.message);
}
*/
