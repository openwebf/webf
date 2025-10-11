declare module '*.css' {
  const styles: {
    use: () => void;
    unuse: () => void;
  };
  export default styles;
}
