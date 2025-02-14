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
    const response = await fetch(`${BASE_URL}${endpoint}`, {
      headers: DEFAULT_HEADERS,
      ...options,
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
    userInfo: () => request('/v1/users/user_info'),
  },

  // News APIs
  news: {
    getHotList: ({ page = 1} = {}) => request(`/v1/feeds/hot?page=${page}`),
    getLatestList: ({ page = 1} = {}) => request(`/v1/feeds/latest?page=${page}`),
    getCommentList: ({ page = 1} = {}) => request(`/v1/feeds/comment?page=${page}`),
    getDisplayList: ({ page = 1, topic = ''} = {}) => request(`/v1/feeds/display?page=${page}&topic=${topic}`),

    getDetail: (id) => request(`/v1/share_links/${id}`),
    publish: (data) => request('/news/publish', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  },

  // Comment APIs
  comments: {
    getList: (newsId) => request(`/comments/${newsId}`),
    create: (data) => request('/comments', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  },
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
