export default function formatAvatar(avatar) {
  if (avatar.startsWith('http')) {
    return avatar;
  }
  return `https://news.miracleplus.com${avatar}`;
}