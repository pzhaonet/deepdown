
<style>
p::before {
  content: "LEADING" counter(paragraph);
  counter-increment: paragraph;
  margin-left: -50px;
  width: 50px;
  height: 0px;
  overflow: visible;
  font-size: 70%;
  display: block;
  color: #666;
}
</style>
